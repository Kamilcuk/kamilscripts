#!/bin/bash

# https://askubuntu.com/questions/888610/trouble-creating-udev-rules-to-run-script-that-loopbacks-a-mic-on-plug

_set_uid() {
	uid=$(id -u "$1") 2>/dev/null
}

# First we need to determine UID of the user we will run stuff as.
if
	[[ "${1:-}" == -u ]] &&
	if _set_uid "$2"; then shift 2; else false; fi
then :; elif
# Try loginctl list-session if there is only one session
	tmp=$(loginctl list-sessions 2>/dev/null) &&
	grep -q '1 sessions' <<<"$tmp" &&
	uid=$(awk '$1 == "1" && $2 ~ /[0-9]+/{print $2}' <<<"$tmp") &&
	_set_uid "$uid"
then :; elif
	# Get UID of user running pulseaudio (uses the first if more than one)
	uid=$(pgrep -f '^/usr/bin/pulseaudio ' | xargs ps -o ruid= -q | awk 'NR==1{print $1}') &&
	_set_uid "$uid"
then :; else
	name=,run_as_main_user_wrapper.sh
	echo "ERROR: $name: Main user running X server not found" >&2
	exit 1
fi

# environment variables to export
if [[ -z "$DISPLAY" ]]; then
	export DISPLAY=:0.0
fi
if [[ -z "$PULSE_RUNTIME_PATH" ]]; then
	export PULSE_RUNTIME_PATH="/var/run/user/$uid/pulse"
fi
HOME="$(getent passwd "$uid" | cut -d: -f6)"
export HOME
if [[ -e "/run/user/$uid/bus" ]]; then
	export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus"
fi

if [[ "${1:-}" == "--debug" ]]; then
	declare -p uid DISPLAY PULSE_RUNTIME_PATH HOME
	exit
fi
if [[ "${1:-}" == "--silence" ]]; then
	exec 1>/dev/null 2>&1
	shift
fi

# Pass single command line arg to user script
sudo -u "#$uid" -E "$@"

