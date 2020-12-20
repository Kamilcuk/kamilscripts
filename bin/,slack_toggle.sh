#!/bin/bash
set -xeuo pipefail

exec 9<"$0"
if ! flock -n 9; then
	exit
fi

if xdotool search --onlyvisible --name 'Slack ' >/dev/null 2>&1; then
	xdotool search --onlyvisible --name 'Slack ' \
		windowactivate --sync %1 \
		key --window %1 --clearmodifiers --delay=0 ctrl+w \
		keyup ctrl \
		keyup meta \
		keyup w \
		keyup d
	not=''
else
	slack &
	not='not'
fi

not() { ! "$@"; }

# wait until the window is ($not) visible
sleep 0.1
while $not xdotool search --onlyvisible --name 'Slack ' >/dev/null 2>&1; do
	sleep 0.1
done

# extra delay to let slack setup 
sleep 0.8


