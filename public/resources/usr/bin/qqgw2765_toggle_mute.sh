#!/bin/bash -xeu

[ "${FLOCKER:-}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

reg=0x8d
dev=dev:/dev/i2c-5
notify-send -t 2000 --icon=dialog-information "Monitor unmuting/muting"
cur=$(ddccontrol -f -r $reg $dev 2>/dev/null | grep "^Control" | cut -d' ' -f3 | cut -d'/' -f2)
if [ "$cur" -eq 1 ]; then
	w=2
	str="un"
else
	w=1
	str=""
fi
ddccontrol -f -r $reg -w $w $dev 2>/dev/null
notify-send -t 2000 --icon=dialog-information "Monitor ${str}muted"

