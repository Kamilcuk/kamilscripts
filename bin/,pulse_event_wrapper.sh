#!/bin/bash

# https://askubuntu.com/questions/888610/trouble-creating-udev-rules-to-run-script-that-loopbacks-a-mic-on-plug

# Get UID of user running pulseaudio (uses the first if more than one)
PUID=$(pgrep -f '^/usr/bin/pulseaudio ' | xargs -i ps -o ruid= -q {} | awk 'NR==1{print $1}')

if [ -z "$PUID" ]; then
	echo "pulseaudio not found" >&2
	exit 1
fi
# environment variables to export
export PULSE_RUNTIME_PATH="/var/run/user/$PUID/pulse"
HOME="$(getent passwd "$PUID" | cut -d: -f6)"
export HOME
# Pass single command line arg to user script
sudo -u "#$PUID" -E "$@"
