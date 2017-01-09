#!/bin/bash

usage() {
	cat << EOF
No Beeps: Short, No power, Bad CPU/MB, Loose Peripherals

One Beep: Everything is normal and Computer POSTed fine
$0 noloop -
Two Beeps: POST/CMOS Error
$0 noloop - -
One Long Beep, One Short Beep: Motherboard Problem
$0 -- -
One Long Beep, Two Short Beeps: Video Problem
$0 -- - -
One Long Beep, Three Short Beeps: Video Problem
$0 -- - - -
Three Long Beeps: Keyboard Error
$0 - - -
Repeated Long Beeps: Memory Error
$0 --
Continuous Hi-Lo Beeps: CPU Overheating 
$0 -_
EOF

}
run() {
	[ $DEBUG -ge 1 ] && echo "+ $@"
	"$@"
}

LOWFREQ=261
HIGHFREQ=523
TIME=${TIME:-500}
LOOPVAR=${LOOPVAR:-true}
DEBUG=${DEBUG:-1}

if [ "$1" == "noloop" ]; then
	LOOPVAR=false
	shift
fi

if [ $# -eq 0 ]; then
	usage;
	exit;
fi

parse_arguments() {
	local IFS=''
	local mnoznik=1;
	local new='';
	beep_args=""
	while read -n1 c; do
		if [ -z "$c" ]; then
			continue;
		fi
		[ $DEBUG -ge 2 ] && echo -n "> $mnoznik*\"$c\" - "
		[ $DEBUG -ge 5 ] && printf "$c" | od -t x1
		case $c in
		"-")  beep_args+="$add -f $HIGHFREQ -l $((mnoznik*TIME)) "; add=" --new "; ;;
		"_")  beep_args+="$add -f $LOWFREQ  -l $((mnoznik*TIME)) "; add=" --new "; ;;
		" ")  beep_args+=" -D $(( mnoznik*TIME )) "; ;;
		*)    ;;
		esac
		case $c in
		1|2|3|4|5|6|7|8|9) mnoznik=$c; [ $DEBUG -ge 1 ] && echo "+ *$mnoznik"; ;;
		*) mnoznik=1; ;;
		esac
	done <<<"$(echo -n "$@"" ")"
}

beep_args=""
parse_arguments "$@"

set -e
beep $beep_args;
while $LOOPVAR; do 
	beep $beep_args;
done
