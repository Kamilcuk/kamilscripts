#!/bin/bash
set -euo pipefail
smartctl=smartctl
if [ -e /usr/sbin/smartctl ]; then
	smartctl=/usr/sbin/smartctl
fi
echo '{"data":['
$smartctl --scan | while read l _; do
	printf "%s" "{\"{#DISC}\":\"$l\","
	$smartctl -i $l | grep ':' | tr -d ' ' | sed 's/\([^:]*\):\(.*\)/"{#\1}":"\2"/' | tr '\n' ',' | sed 's/,$//'
	printf "%s" "},"
done | head -c-1
echo ']}'

