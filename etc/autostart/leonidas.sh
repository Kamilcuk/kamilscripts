#!/bin/bash

if [[ "$HOSTNAME" != 'leonidas' ]]; then return; exit; fi

# xrandr --output HDMI-0 --gamma 0.95:0.97:1.0
# xcalib -a -c ; xcalib -a -red 0.95 0 100 -green 0.97 0 100 -blue 1.00 0 100

,lib_pulseaudio.sh ,pulseaudio_filter_2 'Card' '' '*Built-in Audio*' |
	xargs -i pactl set-card-profile {} output:analog-stereo
,lib_pulseaudio.sh ,pulseaudio_filter_2 'Sink' '' 'Built-in Audio Analog Stereo' |
	xargs -i pactl set-sink-port {} analog-output-lineout

return

runinbg() {
	echo "runinbg: $*"
	( set -x; exec nohup "$@" >/dev/null 2>/dev/null; ) &
}
runbgsl() {
	local sl=$1
	shift
        echo "runbgsl: sleep $sl && $*"
        ( set -x; sleep "$sl"; exec nohup "$@" >/dev/null 2>/dev/null ) &
}
closewindow() {
	set -x
	local w="$(xdotool search "$@")"
	if [ -n "$w" ]; then
	        xdotool windowactivate --sync "$w" key --clearmodifiers  alt+F4
	else
		echo "No windows found for $*" 
	fi
}
gettime() { date '+%s%N'; }
closewindowwait() {
	# closewindowwiat waittime_for_window_to_appear xdotool_search_parameters...
	echo "closewindowwait $*"
	local endtime w
	endtime=$(( $(gettime)+${1:-100}*1000000000 ))
	shift
	while [ $endtime -gt $(gettime) ]; do
		w="$(xdotool search "$@" 2>/dev/null)";
		if [ -n "$w" ]; then
			break;
		fi
		sleep 0.1;
	done
	if [ -n "$w" ]; then
		echo "closewindowwait ^ found window"
	fi
	while [ $endtime -gt $(gettime) ]; do
		if [ -n "$w" ]; then
			xdotool windowactivate --sync "$w" key --clearmodifiers alt+F4
		else
			break
		fi
		w="$(xdotool search "$@" 2>/dev/null)"
		sleep 0.1
	done
	echo "closewindowwait end"
}

{

echo mouse+keyboard settings
( set -x; 
for i in 1 2 3; do
	sleep 1;
	xset m 1/1 1;
	xinput --set-prop "USB Optical Mouse" 'Device Accel Constant Deceleration' 1.5;
	xset r rate 190 29;
	setxkbmap pl;
done
) &

runinbg xbindkeys

# runbgsl 4 TogglDesktop.sh
# { sleep 4; closewindowwait 100 --onlyvisible --name "Toggl Desktop"; } &

} 2>&1 | { while read l; do echo "$(date "+%T:%N") $(basename $0) $*: $l" >&2; done; } & # logs to .xsession-errors


#/home/studia/inzynierka/qqautocopy.sh &
#/home/users/kamil/bin/qqmyirexec.sh &
#xbindkeys &
#transmission-gtk &
#( sleep 1 && for i in $(xdotool search transmission) ; do xdotool windowminimize $i; done; ) &
#sylpheed &
##( sleep 2 && exec thunderbird ) &
#firefox &
#chromium &
#( sleep 1 && for i in $(xdotool search Sylpheed) ; do xdotool windowminimize $i; done; ) &

#( sleep 4; qqmyirexec.sh; ) &
#( sleep 1 ; /usr/bin/xbindkeys ) >/dev/null &
#( sleep 5; 
#(
#sleep 1; 
#xset m 1/1 1;
#xinput --set-prop "USB Optical Mouse" 'Device Accel Constant Deceleration' 1.5; 
#xset r rate 190 29;
#setxkbmap pl;
#) &
#sylpheed &
#( exec chromium >/dev/null 2>/dev/null ) &
#(sleep 5; xset r rate 190 31; ) &
# (sleep 5; transmission-gtk; ) >/dev/null &

#xhost +192.168.1.1
#( exec skype >/dev/null 2>/dev/null ) &
#( exec nohup transmission-gtk >/dev/null 2>/dev/null ) &
#( exec nohup Toggledesktop.sh >/dev/null 2>/dev/null ) &

#


