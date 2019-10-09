#!/bin/bash
set -euo pipefail

n=notifycomplete.sh

usage() {
	cat <<EOF
Usage: $n [options] [message]

Create a popup and play completion sound to notify about a job completion.

Options:
 -h  - print this help and exit

Usage:
  make ; $n $?

Written by Kamil Cukrowski
EOF
}

msg="$n${1:+: }$*"

if hash mpv 2>/dev/null; then
	player="mpv --quiet --terminal"
elif hash mplayer 2>/dev/null; then
        player="mplayer --quiet --terminal"
elif hash vlc 2>/dev/null; then
	player="vlc --intf dummy --play-and-exit --no-video --vout none"
elif hash papley 2>/dev/null && killall -0 pulseaudio; then
	player="papley --volume=65536"
fi

if [ -e /usr/share/sounds ]; then
	if [ -e /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
		music=/usr/share/sounds/freedesktop/stereo/complete.oga
	fi
fi

int_trap() {
	echo
	exit
}
trap int_trap INT

if hash notify-send >/dev/null && [ -n "$DISPLAY" ]; then
	notify-send -i face-surprise "$msg"
fi

if [ -n "$player" -a -n "$music" ]; then
	unset DISPLAY
	while :; do
		if ! $player $music >/dev/null 2>/dev/null; then
			exit
		fi
	done
else
	echo "Could not find the player=$player or music=$music"
fi

