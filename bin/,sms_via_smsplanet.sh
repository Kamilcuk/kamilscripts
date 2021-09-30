#!/bin/sh
name=$(basename "$0")
to_html() {
	xxd -p | tr -d '\n' | sed 's/../%&/g'
}
usage() {
	cat <<EOF
Usage: $name [Options] <sendto> <subject> <message>

Options:
  -f <from>   By default from "Zabbix"
  -T          Test mode instead of send
  -h

Example:
  $name 605177789 TEST "Testowy sms"
See https://panel.smsplanet.pl/s/api?tab=tab2
See https://smsplanet.pl/integracja.html

Written by Kamil Cukrowski 2019
EOF
}
fatal() {
	echo "$name: Error:" "$*" >&2
	exit 2
}

# Main #########################

from=Zabbix
echo=
while getopts "f:Th" arg; do
	case "$arg" in
	f) from=$OPTARG; ;;
	T) echo="echo"; ;;
	h) usage; exit; ;;
	*) usage; exit 1; ;;
	esac
done
shift $((OPTIND-1))
if [ "$#" -ne 3 ]; then
	fatal "Wrong number of arguments. See $name -h"
fi

to=$1
subject=$2
body=$3

msg=$(printf "%s\n%s" "$subject" "$body" | to_html)

resp=$(
	$echo curl -X POST -G 'https://api2.smsplanet.pl/sms' \
		-d key="${SMSPLANET_KEY%:*}" \
		-d password="${SMSPLANET_KEY#*:}" \
		-d to="$to" \
		-d from="$from" \
		-d msg="$msg" &&
	if [ -n "$echo" ]; then
		echo "{\"messageId\":\"1254851\"}"
	fi
)
ret=$?
printf "%s\n" "$resp"
if ! { printf "%s\n" "$resp" | grep -q "{\"messageId\":\"[0-9]\+\"}" ;}; then
	exit 1
fi
exit "$ret"

