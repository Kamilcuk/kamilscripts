#!/bin/bash
set -xeuo pipefail

exec 9<"$0"
if ! flock -n 9; then
	exit
fi

if v=$(xdotool search --onlyvisible --name 'Slack '); then
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
	not='!'
fi

# wait until the window is ($not) visible
sleep 0.1
while
	if [ "$not" = '!' ]; then
		! xdotool search --onlyvisible --name 'Slack ' >/dev/null 2>&1
	else
		xdotool search --onlyvisible --name 'Slack ' >/dev/null 2>&1
	fi
do
	sleep 0.1
done

# extra delay to let slack setup 
sleep 0.8


