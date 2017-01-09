#!/bin/bash

# global and init
unset -f : # in case !
rep=; key=;

notify() {
	notify-send -t 1000 "$1"
	shift; $@
}
notifyOnce() {
	[[ $rep != 00 ]] && return
	local var="$1"; shift; notify "$var" $@
}
notifyOmit() {
	[[ $rep =~ $1 ]] && return
	shift; local var="$1"; shift; notify "$var" $@
}
notifyOnly() {
	[[ $rep =~ $1 ]] || return
	shift; local var="$1"; shift; notify "$var" $@
}

checkActiveWindowName() {
	[[ "$(xdotool getwindowname $(xdotool getactivewindow))" =~ .?${1}.? ]] && return 0 || return 1
}
runIfVlc() {
	checkActiveWindowName VLC      && { $@; return 0; } || return 1;
}
runIfSMPlayer() {
	checkActiveWindowName SMPlayer && { $@; return 0; } || return 1;
}

program() {
#$ irw
#0000000040bff807 00 KEY_VOLUMEUP rmfp
#0000000040bff807 01 KEY_VOLUMEUP rmfp
	rep=$2 # from repeat
	key=$3
test "$rep" == 00 && return

case $key in placeholder) echo
#;; KEY_POWER)
;; KEY_CYCLEWINDOWS) [[ $rep == 01 ]] && xdotool keydown alt key Tab keyup alt;
;; KEY_1) xdotool mousemove_relative --sync -- -40 -40
;; KEY_2) xdotool mousemove_relative --sync --   0 -10
;; KEY_3) xdotool mousemove_relative --sync --  40 -40
;; KEY_4) xdotool mousemove_relative --sync -- -10   0
;; KEY_5) notifyOnce "Click 1" xdotool click 1
;; KEY_6) xdotool mousemove_relative --sync --  10   0
;; KEY_7) xdotool mousemove_relative --sync -- -40  40
;; KEY_8) xdotool mousemove_relative --sync --   0  10
;; KEY_9) xdotool mousemove_relative --sync --  40  40
;; KEY_0) notifyOnce "Click 1 twice!" xdotool click 1 click 1
#;; display)
#;; snapshot)
#;; chrtn)
#;; chprev)
#;; KEY_CHANNELUP) 
#;; KEY_CHANNELDOWN) 
;; KEY_VOLUMEDOWN) 	notifyOmit "(01|02|03)" 'Vol DOWN' amixer -q sset Master 2-
;; KEY_VOLUMEUP) 	notifyOmit "(01|02|03)" 'Vol UP  ' amixer -q sset Master 2+
;; KEY_F11) 		notifyOnce 'Fullscreen' xdotool key F11
;; KEY_MUTE) 		notifyOnce 'MUTE' amixer -q sset Master toggle
#;; KEY_AUDIO)
#;; KEY_RECORD)
#;; KEY_PLAY) runIfSMPlayer notifyOnce SMPlayer PLAY xdotool key space
#;; KEY_STOP)
#;; KEY_PAUSE) 
#;; KEY_REWIND)
#;; KEY_FORWARD)
#;; KEY_TEXT)
#;; KEY_LAST)
#;; KEY_NEXT)
#;; KEY_EPG)
#;; KEY_MENU)
esac
}

waitforFile() {
	local file=$1
	while [ ! -e "$file" ]
	do
	    inotifywait -qqt 2 -e create -e moved_to "$(dirname $file)"
	done
}

waitforFile  /var/run/lirc/lircd
irw | while read but; do
	program $but
done





