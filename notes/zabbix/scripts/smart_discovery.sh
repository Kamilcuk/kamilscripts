#!/bin/bash
set -euo pipefail
export PATH="$PATH:/usr/sbin"
echo '{"data":['
smartctl --scan | while read -r l _; do
	printf "%s" "{\"{#DISC}\":\"$l\","
	smartctl -i "$l" | grep ':' | tr -d ' ' | sed 's/\([^:]*\):\(.*\)/"{#\1}":"\2"/' | tr '\n' ',' | sed 's/,$//'
	printf "%s" "},"
done | head -c-1
echo ']}'

