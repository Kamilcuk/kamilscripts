#!/bin/bash
set -euo pipefail

name=org.freedesktop.Notifications.Notify

fatal() {
	echo "$name: ERROR: $*" >&2
	exit 2
}

usage() {
	cat <<EOF
Usage:
	$name app_name replaces_id app_icon summary body [actions] [hints] [expire_timeout] [tempfile]
	$name [options] app_name

Options:
   -r replaces_id
   -i app_icon
   -s summary
   -b body
   -a actions
   -H hints
   -t expire_timeout
   -T tempfile
   -P                  Create tempfile in /tmp from app_name
   -d                  Enable debug
   -h                  Print this help and exit.

Call org.freedesktop.Notifications.Notify function using gdbus.
Optional tempfile is used for caching notification number.
If tempfile is given, replaces_id is ignored.
Returns created notification number.


Examples:
	$name \
		"Audio monitor" 0 "audio-headphones" "Audio status" "Audio via headphones" "" "" "" "/tmp/tempfile-audiomon"
	$name \
		-i audio-headphones -s "Audio status" -m "Audio via headphones" -P "Audio monitor"

Written by Kamil Cukrowski
EOF
}

args=$(getopt -n "$name" -o "r:i:s:b:a:h:t:T:Pdh" -- "$@")
eval "set -- $args"
debug=0
quiet=0
replaces_id=0
app_icon=''
summary=''
body=''
actions='[]'
hints='{}'
expire_timeout=5000
tempfile=''
tempfilefromappname=0
while (($#)); do
	case "$1" in
	-r) replaces_id="$2"; shift; ;;
	-i) app_icon="$2"; shift; ;;
	-s) summary="$2"; shift; ;;
	-b) body="$2"; shift; ;;
	-a) actions="$2"; shift; ;;
	-H) hints="$2"; shift; ;;
	-t) expire_timeout="$2"; shift; ;;
	-T) tempfile="$2"; shift; ;;
	-P) tempfilefromappname=1; ;;
	-d) debug=1; echo "$args" >&2; ;;
	-h) usage; exit; ;;
	--) shift; break; ;;
	*) fatal "Unhandled argument: $1" ;;
	esac
	shift
done

app_name=$1
if (($# != 1)); then
	if (($# < 5 || $# > 9)); then
		usage
		fatal "Wrong number of arguments"
	fi
	replaces_id=$2
	app_icon=$3
	summary=$4
	body=$5
	actions=${6:-$actions}
	hints=${7:-$hints}
	expire_timeout=${8:-$expire_timeout}
	tempfile=${9:-}
fi
if ((tempfilefromappname)); then
	if [[ -n "${tempfile:-}" ]]; then
		fatal "Both options -T and -P given"
	fi
	: "${tempfile:="/tmp/.org.freedesktop.Notifications.Notify-$app_name"}"
fi

if [[ -n "$tempfile" ]]; then
	quiet=1
	if [[ -r "$tempfile" ]]; then
		read -r replaces_id childpid <"$tempfile"
		if ! kill "$childpid"; then
			echo "ERROR: killing child failed, trying to go on: $tempfile" >&2
			rm -f "$tempfile"
		fi
	else
		replaces_id=0
	fi
fi

ret=$(
	if ((${NOTIFY_DEBUG:-0} || debug)); then set -x; fi;
  	gdbus call --session \
	    --dest org.freedesktop.Notifications \
	    --object-path /org/freedesktop/Notifications \
	    --method org.freedesktop.Notifications.Notify \
	    "$app_name" "$replaces_id" "$app_icon" "$summary" "$body" "$actions" "$hints" "$expire_timeout"
)
# ret looks like '(uint32_t 250,)'
IFS=' ,' read -r _ id _ <<<"$ret"

if [[ -n "$tempfile" ]]; then
	sleepval1=$((expire_timeout / 1000))
	sleepval2=$((expire_timeout % 1000))
	sleepval=$sleepval1.$sleepval2
	( sleep "$sleepval"; rm "$tempfile"; ) &
	childpid=$!
	echo "$id $childpid" >"$tempfile"
fi

if ((!quiet)); then
	echo "$id"
fi

