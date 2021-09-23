#!/bin/bash
set -euo pipefail

name=$(basename "$0")
usage() {
	cat <<EOF
Usage: $name [float]

Examples:
	$name +0.1
	$name -0.2
	$name -2

EOF
}

if (($# != 1)); then
	usage
	exit 1
fi
if [[ ! "$1" =~ ^[+-]?([0-9]+\.?[0-9]*|[0-9]*\.[0-9]+)$ ]]; then
	usage
	echo "$name: ERROR: Argument is not a float: $1" >&2
	exit 1
fi

xrandr --verbose |
awk '
	$2 ~ "^connected$"{n[i++]=$1}
	/Brightness/{b[i-1]=gensub(/.*: */, "", "1", $0)}
	END{for (i in n) print n[i], b[i]}
' | {
while read -r name val; do
	case "${1:0:1}" in
		[+-]) val=$(awk -v val="$val" -v inc="$1" 'BEGIN{print val + inc}' <&-); ;;
	esac
	xrandr --output "$name" --brightness "$val"
	barlen=$(awk -v val="$val" 'BEGIN{print int(val*100)}' <&-)
done
org.freedesktop.Notifications.Notify.sh "$name" 0 "dialog-information" "Screen brightness notification" "Screen brightness: $(printf "%-3s" "$barlen")/100" "" "{'value':<${barlen}>}" 2000 /tmp/.notifyval."$name" >/dev/null
}
