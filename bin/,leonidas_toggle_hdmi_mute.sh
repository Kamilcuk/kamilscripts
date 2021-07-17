#!/bin/bash

tmp=$(,pulseaudio_lib list_2 "_what,_num,_description,mute" | awk -F'\t' -v OFS='\t' '
	$1 !~ "Sink"{next}
	$3 ~ /^GP107GL.*HDMI/{print "sink_hdmi="$2" sink_hdmi_muted="$4}
	$3 ~ /^Built-in Audio Analog Stereo/{print "sink_builtin="$2" sink_builtin_muted="$4}
	$3 ~ /^IBH 2100-TI$/{print "bluehead="$2}
'
)
declare $tmp


if (($# == 0)); then
	if [[ -n "${bluehead:-}" ]]; then
		set -- only_bluetooth
	elif [[ "${sink_hdmi_muted,,}" =~ no ]]; then
		set -- unmute_headphones
	else
		set -- unmute_hdmi
	fi
fi

pactl set-sink-volume "$sink_hdmi" 100%
pactl set-sink-volume "$sink_builtin" 100%
case "$1" in
unmute_headphones)
	pactl set-sink-mute "$sink_hdmi" on
	pactl set-sink-mute "$sink_builtin" off
	icon=audio-headphones
	msg="Dźwięk przez słuchawki. Monitor wyciszony"
	;;
unmute_hdmi)
	pactl set-sink-mute "$sink_hdmi" off
	pactl set-sink-mute "$sink_builtin" on
	icon=video-display
	msg="Dźwięk przez monitor. Słuchawki wyciszone"
	;;
only_bluetooth)
	pactl set-sink-mute "$sink_hdmi" on
	pactl set-sink-mute "$sink_builtin" on
	pactl set-sink-mute "$bluehead" off
	pactl set-sink-mute "$bluehead" off
	icon=blueman
	msg="Dźwięk przez słuchawki bluetooth."
	;;
*)
	echo "Invalid command" >&2
	exit 1
	;;
esac
	
org.freedesktop.Notifications.Notify.sh "$(basename $0)" 0 "$icon" \
	"$msg" \
	"Monitor mute status" "" "" "" /tmp/.notifyval."$(basename $0)" >/dev/null

,pulseaudio_lib filter_2 'Card' '' '*Built-in Audio*' | xargs -i pactl set-card-profile {} output:analog-stereo
,pulseaudio_lib filter_2 'Sink' '' 'Built-in Audio Analog Stereo' | xargs -i pactl set-sink-port {} analog-output-lineout

