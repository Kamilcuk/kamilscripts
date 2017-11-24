#!/bin/bash
# Written by Kamil Cukrowski (C) 2017. Under MIT License
#
set -euo pipefail

TEST=${TEST:-false}
NAME=systemd-failure-monitor.sh

# functions ###################################

usage() {
	cat <<EOF
Usage:  $NAME [options] <email address>

Options:
	-i, --ignore <name> - ignore services that match name
	-d, --no-duplicate  - don't send email on duplicated fails

Scirpt monitors journalctl for failed jobs/services.
In case of a failed job/service, it sends email to designated address.

Example:
	$NAME your_email@gmail.com
	$NAME -

Written by Kamil Cukrowski (C) 2017. Under MIT License
EOF
}

output() {
	local MAILTO=$1 UNIT=$2 
	local status hostname journalctl tmp
	hostname=$(hostname)
	status=$(systemctl status $UNIT -l --no-pager || :)
	journal=$(journalctl -n -0 -u $UNIT -n100 || :)
	tmp=$(cat <<EOF
To: $MAILTO
Subject: $hostname: Unit $UNIT entered failed state.

Unit $UNIT entered failed state on machine $hostname

- Additional information ----------------------------------------------------
- systemctl status $UNIT -l -------------------------------------------------
$status

- journalctl -n -0 -u $UNIT -n100 -------------------------------------------
$journal
-----------------------------------------------------------------------------

This email is generated automatically by $0 script.
Refer to your configuration for knowing the hell is going on.

Have a nice day,
$0 script.
EOF
	)
	case "$MAILTO" in
	*@*.*) sendmail $MAILTO; ;;
	stdout|-) cat; ;;
	quiet) cat >/dev/null; ;;
	esac <<<"$tmp";
}

do_output() {
	local -g listAlreadyFailed
	local MAILTO=$1 UNIT=$2 noduplicate=$3 tmp
	if $noduplicate; then
		if [ -z "${listAlreadyFailed+x}" ]; then listAlreadyFailed=""; fi
		if grep -x -q "$UNIT" <<<"$listAlreadyFailed"; then
			log "$UNIT entered failed state again."
			return
		fi
		listAlreadyFailed+="$UNIT"$'\n'
	fi
	echo "$UNIT entered failed state -> output to $MAILTO"
	if ! output "$MAILTO" "$UNIT"; then
		echo "Error outputing to $MAILTO about $UNIT"
	fi
}

# main #################################################

# Parse Arguments
if [ $# -lt 1 ]; then usage; exit 1; fi
if ! ARGS=$(getopt -n "$NAME" -o i:d -l ignore:no-duplicate -- "$@"); then
	echo "Error parsing options" >&2; exit 1;
fi
eval set -- "$ARGS"

ignore="" noduplicate=false
while true; do
	case "$1" in
		-i | --ignore ) ignore+="$2"$'\n'; shift; ;;
		-d | --no-duplicate) noduplicate=true; ;;
		-- ) shift; break; ;;
		* ) echo "internal error $1" >&2; exit 1; ;;
	esac
	shift
done

MAILTO=$1
shift
if [ $# -ne 0 ]; then usage; echo "Additional arguments on the end" >&2; exit 1; fi;

# Check arguments
ignore=$(sort <<<"$ignore")
echo "Init. Output is $MAILTO";

set -reuo pipefail

while IFS=':' read -r UNIT _; do 
	if grep -x -q "$UNIT" <<<"$ignore"; then
		continue;
	fi
	do_output "$MAILTO" "$UNIT" "$noduplicate"	
done < <( 
	grep --line-buffered "[Ff]ailed with result" \
		<(journalctl --boot=0 --identifier=systemd --follow --output=cat --no-pager --no-hostname -n1000000)
)

