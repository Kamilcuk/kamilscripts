#!/bin/bash

if [[ "$HOSTNAME" != 'gorgo' ]]; then return; exit; fi

xcalib -a -c
xcalib -a -red 1.05 1 100 -green 1.13 1 100 -blue 1.35 1 100
# xcalib -a -red 0.90 1 100 -green 1.05 1 100 -blue 1.20 1 100
xmodmap -e 'keycode XF86Forward=' -e 'keycode XF86Back=' -e 'keycode 111=Up' -e 'keycode 167=' -e 'keycode 166='
case "$(,x_get_monitors | awk '{print $1}' | sort | paste -sd' ')" in
"DP-2 LVDS-1")
	# w pracy
	xrandr --output DP-1 --auto --pos  0x0 --output LVDS-1 --auto --pos 2560x672
	xrandr --output DP-2 --auto --pos  0x0 --output LVDS-1 --auto --pos 2560x672
	;;
esac

