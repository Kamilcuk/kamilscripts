#!/bin/bash
set -euo pipefail
export SHELLOPTS

LOGLVL=${LOGLVL:-0}
TEST=${TEST:-false}
NAME=$(basename $0)

# functions ###################################

usage() {
	cat <<EOF
Usage:  $NAME [options] <email address>

Options:
 -c, --config <path>   source path before executing
 -i, --ignore <name>   ignore services that match name
 -d, --no-duplicate    don't send email on duplicated fails
 -h, --help            print this text and exit

Scirpt monitors journalctl for failed jobs/services.
In case of a failed job/service, it sends email to designated address.

Example:
	$NAME your_email@gmail.com
	$NAME -

Written by Kamil Cukrowski (C) 2017. Under MIT License
EOF
}

# overwrite that function in your config file

output() {
	local mailto unit footer
	mailto=$1
	unit=$2 
	footer=""
	case "$mailto" in
	*@*.*) sendmail $mailto; ;;
	stdout|-) cat; ;;
	stderr) cat >&2; ;;
	quiet) cat >/dev/null; ;;
	esac <<EOF
To: $mailto
Subject: $(hostname): Unit $unit entered failed state.

- Unit $unit entered failed state on machine $(hostname)
- Additional information ----------------------------------------------------
- systemctl status $unit -l -------------------------------------------------
$(systemctl status $unit -l --no-pager ||:)

- journalctl -n -0 -u $unit -n100 -------------------------------------------
$(journalctl -n -0 -u $unit -n100 ||:)
-----------------------------------------------------------------------------

This email is generated automatically by $0 script.
Refer to your configuration for knowing the hell is going on.

Have a nice day,
$0
EOF
}

listAlreadyFailed=""
do_output() {
	local -g listAlreadyFailed
	local mailto unit noduplicate tmp
	mailto=$1
	unit=$2
	noduplicate=$3

	if $noduplicate; then
		if [ -z "${listAlreadyFailed+x}" ]; then
			listAlreadyFailed="";
		fi
		if grep -x -q "$unit" <<<"$listAlreadyFailed"; then
			echo "$unit entered failed state again, thus is ignored."
			return
		fi
		listAlreadyFailed+="$unit"$'\n'
	fi

	echo "$unit entered failed stata. Outputing to $mailto"
	if ! output "$mailto" "$unit"; then
		echo "warn: Outputing to $mailto about $unit exited with error"
	fi
}

# main #################################################

# Parse Arguments
if [ $# -lt 1 ]; then usage; exit 1; fi
if ! ARGS=$(
	getopt \
		-n "$NAME" \
		-o c:i:dh \
		-l config:,ignore:,no-duplicate,help \
		-- "$@"
		); then
	echo "Error: parsing options" >&2; exit 1;
fi
eval set -- "$ARGS"

ignore="" noduplicate=false
while true; do
	case "$1" in
	-c|--config) . "$2"; shift; ;;
	-i|--ignore) ignore+="$2"$'\n'; shift; ;;
	-d|--no-duplicate) noduplicate=true; ;;
	-h|--help) usage; exit 1; ;;
	--) shift; break; ;;
	*) echo "Error: internal error $1" >&2; exit 1; ;;
	esac
	shift
done

if [ $# -eq 0 ]; then usage; echo "Error: missing arguments" >&2; exit 1; fi;
MAILTO=$1
shift
if [ $# -ne 0 ]; then usage; echo "Additional arguments on the end" >&2; exit 1; fi;

# Check arguments
ignore=$(sort -u <<<"$ignore")
echo "Init. Output is $MAILTO";

set -euo pipefail

journalctl --boot=0 --identifier=systemd --follow --output=cat --no-pager --no-tail |
grep --line-buffered "[Ff]ailed with result" |
while IFS=':' read -r UNIT _; do 
	if grep -x -q "$UNIT" <<<"$ignore"; then
		continue;
	fi
	do_output "$MAILTO" "$UNIT" "$noduplicate"	
done

