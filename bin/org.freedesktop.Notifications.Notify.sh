#!/bin/bash
set -euo pipefail

: "${DEBUG:=false}"

usage() {
	n=$0
	cat <<EOF
Usage:
	$n app_name replaces_id app_icon summary body actions hints expire_timeout [tempfile]

Call org.freedesktop.Notifications.Notify function using gdbus.
Optional tempfile is used for caching notification number.
If tempfile is given, replaces_id is ignored.
Returns created notification number.

Written by Kamil Cukrowski
EOF
}

if (($# < 8 || $# > 9)); then
	usage >&2
	echo
	echo "ERROR: Wrong number of arguments" >&2
	exit 1
fi

app_name=$1
replaces_id=$2
app_icon=$3
summary=$4
body=$5
actions=${6:-[]}
hints=${7:-{\}}
expire_timeout=${8:-5000}
tempfile=${9:-}

if [ -n "$tempfile" ]; then
	if [ -r "$tempfile" ]; then
		filecontent=$(cat "$tempfile")
		read -r replaces_id childpid <<<"$filecontent"
		if ! kill "$childpid"; then
			echo "ERROR: killing child failed, trying to go on" >&2
			rm "$tempfile"
			replaces_id=0
		fi
	else
		replaces_id=0
	fi
fi

ret=$(
  if $DEBUG; then set -x; fi;
  gdbus call --session \
    --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.Notify \
    "$app_name" "$replaces_id" "$app_icon" "$body" "$summary" "$actions" "$hints" "$expire_timeout"
)

# ret looks like '(uint32_t 250,)'
ret=$(tr ',' ' ' <<<"$ret")
read -r _ ret _ <<<"$ret"
if [ "$ret" -ne "$ret" ]; then echo "ERROR: return value is not a number" >&2; exit 1; fi;


if [ -n "$tempfile" ]; then
	sleepval1=$((expire_timeout/1000))
	sleepval2=$((expire_timeout%1000))
	sleepval=$sleepval1.$sleepval2
	( sleep "$sleepval"; rm "$tempfile"; ) &
	childpid=$!
	echo "$ret" "$childpid" >"$tempfile"
	
fi
echo "$ret"

