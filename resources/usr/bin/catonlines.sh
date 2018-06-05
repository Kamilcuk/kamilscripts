#!/bin/bash
set -euo pipefail; export SHELLOPTS

# Functions

version() {
	cat <<EOF
catonlines.sh 0.0.1
Written by Kamil Cukrowski 2018.
Licensed jointly under MIT License and Beeware License.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
EOF
}

usage() {
	cat <<EOF
Usage: catonlines.sh [OPTION]... [STREAM]...
Print streams with each stream on dedicated lines

With no STREAM or when STREAM is -, read standard input.

  -r, --rows=<NUM>          span output on this many rows
  -c, --max-columns=<NUM>   limit maximum number of columns
  -w, --wrap-columns=<NUM>  wrap columns longer then NUM
  -f, --fullscreen          occupy full screen
  -m, --mode=<NUM>          use mode equal to NUM
  -h, --help                display this help and exit
  -v, --version             display version information and exit

Examples:
  catonlines.sh <(ping www.google.com) <(ping www.bing.com)

EOF
	version
}

selftest() {
	f() { 
		seq "${1:-100}" | xargs -n1 /bin/sh -c "echo ${2:-$BASHPID} \"\$1\"; sleep ${3:-0.1}" -- ;
	}
	$0 <(f) <(f) <(f) <(f)
}

# Main

ARGS=$(getopt -n catonlines.sh \
	-o r:c:w:fm:hv \
	-l rows:,max-columns:,wrap-columns:,fullscreen,mode:help,version \
	-- "$@")
rows=1 wrapcolumns= maxcolumns= fullscreen=false mode=3
eval set -- "$ARGS"
while true; do
	case "$1" in	
	-r|--rows) rows=$2; shift; ;;
        -c|--max-columns) maxcolumns=$2; shift; ;;
	-w|--warp-columns) wrapcolumns=$2; shift; ;;
        -f| --fullscreen) fullscreen=true; ;;
	-m|--mode) mode=$2; shift; ;;
	-h|--help) usage; exit; ;;
	-v|--version) version; exit; ;;
	--) shift; break; ;;
	*) echo "ERROR: parsing arguments" >&2; exit 1; ;;
	esac
	shift
done

if [ $# -eq 0 ]; then
	set -- -
fi

if $fullscreen; then
	clear
else
	printf '%.0s\n' $(seq $(($#*rows)))
fi

case "$mode" in
0)
f() {
	local str
	str='\033[s\033['"$1"'A\033[2K'"$(seq 2 $rows | xargs -I{} echo -ne '\033[1A\033[2K')"'%s\033[u'
	${maxcolumns:-cat}${maxcolumns:+stdbuf -oL cut -c 1-$maxcolumns} | \
	${wrapcolumns:-cat}${wrapcolumns:+stdbuf -oL fold -w $wrapcolumns} | \
	while IFS='' read -r l; do
		for (( i = 1; i < rows; ++i)); do
			IFS='' read -r tmp
			l+=$'\n'"$tmp"
		done
		flock 1
		printf "$str" "$l"
		flock -u 1
	done || :
}
trap 'if [ -n "${childs:-}" ]; then kill $childs; fi; wait;' SIGCHLD EXIT
childs=""
for ((i = 2; i <= $#; ++i)); do
	( f $((i * rows)) < "${!i}" ) &
	childs+=" $!"
done
f $((rows)) < "$1"
wait
trap '' EXIT SIGCHLD
;;
1)
printf "$(printf '%d\\000%%s\\000' $(seq 1 $rows $(($#*$rows))))" "$@" \
| xargs -0 -n 2 -P 0 bash -c \
"cat \"\$2\" | $(
	echo -n "${maxcolumns:+stdbuf -oL cut -c 1-$maxcolumns | }" 
	echo -n "${wrapcolumns:+stdbuf -oL fold -w $wrapcolumns | }"
)while IFS='' read -r l1 $(seq 2 $rows | xargs -I{} echo -n "&& { IFS='' read -r l{} || :; }"); do 
	flock 1
	printf '\\033[s\\033['\"\$1\"'A\\033[2K$(seq 2 $rows | xargs -I{} echo -n '\033[1A\033[2K')%s\\033[u' \"\${l1}$(
		seq 2 $rows | xargs -I{} echo -n $'\n'"\${l{}}"
)\"
	flock -u 1
done" --
;;
2)
printf "$(printf '%d\\000%%s\\000' $(seq 1 $rows $(($#*$rows))))" "$@" \
| xargs -0 -n 2 -P 0 sh -c \
"cat \"\$2\" | $(
        echo -n "${maxcolumns:+stdbuf -oL cut -c 1-$maxcolumns | }" 
        echo -n "${wrapcolumns:+stdbuf -oL fold -w $wrapcolumns | }"
)awk '{l=\$0;$(
	seq 2 $rows | xargs -I{} echo -n 'getline t;l=l "\n" t;'
)printf \"\\033[s\\033['\"\$1\"'A\033[2K$(
	seq 2 $rows | xargs -I{} echo -n '\033[1A\033[2K'
)%s\\033[u\",l;fflush();}'" --
;;
3)
printf "$(printf '%d\\000%%s\\000' $(seq 1 $rows $(($#*$rows))))" "$@" \
| xargs -0 -n 2 -P 0 sh -c \
"cat \"\$2\" | $(
        echo -n "${maxcolumns:+stdbuf -oL cut -c 1-$maxcolumns | }" 
        echo -n "${wrapcolumns:+stdbuf -oL fold -w $wrapcolumns | }"
)sed 's/^/\c[[s\c[['\"\$1\"'A\c[[2K$(
	seq 2 $rows | xargs -I{} echo -n '\c[[1A\c[[2K'
	printf /\;
	seq 2 $rows | xargs -I{} echo -n N\;
)s/$/\c[[u\c[[1A/'" -- 2>/tmp/1
;;
*)
echo "ERROR: Wrong mode chosen" >&2
exit 1
;;
esac
