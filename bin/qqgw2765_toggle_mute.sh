#!/bin/bash -u

DEBUG=${DEBUG:-false}
$DEBUG && set -x

if [ "${FLOCKER:-}" != "$0" ]; then
	exec env FLOCKER="$0" flock -en "$0" "$0" "$@"
fi

reg=0x8d
dev=5
declare -A ddcci_res
eval "$(qqddcci.sh -q -i $dev -r $reg | grep ddcci_res)"
cur=${ddcci_res[present]}
if [ "$cur" -eq 1 ]; then
	w=2
	str="un"
else
	w=1
	str=""
fi
notify-send -t 2000 --icon=dialog-information "Monitor ${str}muted" &
qqddcci.sh -q -i $dev -r $reg -w $w >/dev/null
wait

