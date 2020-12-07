#!/bin/bash

. ,lib_pulseaudio.sh
tmp=$(,pulseaudio_list_2 "_what,_num,_description,mute" | awk -F'\t' -v OFS='\t' '
	$1 !~ "Sink"{next}
	$3 ~ /^GP107GL.*HDMI/{print "sink_hdmi="$2" sink_hdmi_muted="$4}
	$3 ~ /^Built-in Audio Analog Stereo/{print "sink_builtin="$2" sink_builtin_muted="$4}
'
)
declare $tmp

muted=$(if [[ "${sink_hdmi_muted,,}" =~ no ]]; then echo true; else echo false; fi)

,lib_pulseaudio.sh ,pulseaudio_filter_2 'Card' '' '"Built-in Audio"' | xargs -i pactl set-card-profile {} output:analog-stereo
,lib_pulseaudio.sh ,pulseaudio_filter_2 'Sink' '' 'Built-in Audio Analog Stereo' | xargs -i pactl set-sink-port {} analog-output-lineout
if "$muted"; then
	pactl set-sink-mute "$sink_hdmi" on
	pactl set-sink-mute "$sink_builtin" off
	icon=audio-volume-muted
	muted="Off"
else
	pactl set-sink-mute "$sink_hdmi" off
	pactl set-sink-mute "$sink_builtin" on
	icon=audio-volume-high
	muted="On"
fi
	
org.freedesktop.Notifications.Notify.sh "$(basename $0)" 0 "$icon" \
	"$muted" \
	"Monitor mute status" "" "" "" /tmp/.notifyval.$(basename $0) >/dev/null


