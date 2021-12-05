#!/bin/bash

# https://askubuntu.com/questions/888610/trouble-creating-udev-rules-to-run-script-that-loopbacks-a-mic-on-plug

name=,run_as_main_user_wrapper

log() {
	echo "$name: $*" >&2
}

fatal() {
	log "ERROR: $*"
	exit 2
}

appendpath () {
	case ":$PATH:" in
		*:"$1":*) ;;
		*) PATH="${PATH:+$PATH:}$1"; ;;
	esac
}

set_uid() {
	uid=$(id -u "$1") 2>/dev/null
}

###############################################################################

usage() {
	cat <<EOF
Usage: $name [options] cmd [args...]

Optiosn:
  -u <user>  Run as that user
  -d         Debug
  -s         Redirect stdout and stderr to /dev/null
  -U         Run from UDEV
  -N         Disable udev detection (TODO)
  -h         Print this help and exit

EOF
}

uid=''
debug=0
silence=0
udev=0
noudev=0
while getopts u:dsUh opt; do
	case "$opt" in
	u) if ! set_uid "$OPTARG"; then uid=''; fi; ;;
	d) debug=1; ;;
	s) silence=1; ;;
	U) udev=1; ;;
	N) noudev=1; ;;
	h) usage; exit 0; ;;
	*) fatal "Invalid flag"; ;;
	esac
done
shift "$((OPTIND - 1))"

if ((!$#)); then
	echo "FATAL: Missing command to run" >&2
	exit 1
fi

# First we need to determine UID of the user we will run stuff as.
if [[ -n "${uid:-}" ]]; then
	:
elif
# Try loginctl list-session if there is only one session
	tmp=$(loginctl list-sessions 2>/dev/null) &&
	grep -q '1 sessions' <<<"$tmp" &&
	uid=$(awk '$1 == "1" && $2 ~ /[0-9]+/{print $2}' <<<"$tmp") &&
	set_uid "$uid"
then :; elif
	# Get UID of user running pulseaudio (uses the first if more than one)
	uid=$(pgrep -f '^/usr/bin/pulseaudio ' | xargs ps -o ruid= -q | awk 'NR==1{print $1}') &&
	set_uid "$uid"
then :; else
	fatal "Could not determine main user"
fi

# Automatically detect udev from environment variables
if ((!udev)); then
	if [[ -n "${SUBSYSTEM:-}" && -n "${DEVPATH:-}" && -n "${ID_PATH:-}" ]]; then
		udev=1
	fi
fi
if ((udev)); then
	export UDEV=1
fi

# environment variables to export
{
	if [[ -z "${DISPLAY:-}" ]]; then
		export DISPLAY=:0.0
	fi
	if [[ -z "${PULSE_RUNTIME_PATH:-}" && -e "/var/run/user/$uid/pulse" ]]; then
		export PULSE_RUNTIME_PATH="/var/run/user/$uid/pulse"
	fi
	if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -e "/run/user/$uid/bus" ]]; then
		export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus"
	fi
	HOME="$(getent passwd "$uid" | cut -d: -f6)"
	export HOME
	if [[ -r ~/.kamilscripts ]]; then
		appendpath ~/.kamilscripts/bin
		export PATH
	fi
}

# Run the command via sudo
cmd=(sudo -u "#$uid" -E "$@")
if ((debug)); then
	declare -p uid DISPLAY PULSE_RUNTIME_PATH HOME PATH cmd silence
	exit
fi
if ((silence)); then
	exec 1>/dev/null 2>&1
fi
if ((!udev)); then
	"${cmd[@]}"
else
	# When in udev, run in background and enable logging.
	{
		echo "+ $*"
		"${cmd[@]}"
	} 2>&1 | logger -t "$1" -p local3.info &
fi

