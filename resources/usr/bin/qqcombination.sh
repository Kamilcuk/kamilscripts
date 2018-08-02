#!/bin/bash
set -euo pipefail

: "${OUTSEP:=$'\t'}"
: "${LINESEP:=$'\n'}"
: "${WITH_REPETITION:=true}"

arr_join() {
	local sep
	sep="$1"
	shift
	printf "%s" "$1"
	shift
	while (($#)); do
		printf "%s%s" "$sep" "$1"
		shift
	done
}

combination() {
	local -g OUTSEP
	local -g LINESEP
	local -g WITH_REPETITION
	local max num
	max=$1
	num=$2
	shift 2
	if [ "$max" -eq "$num" ]; then
		arr_join "$OUTSEP" "${@:1:$num}"
		printf "%s" "$LINESEP"
		return
	fi

	local pre
	pre=("${@:1:$num}")
	shift "$num"
	((++num))
	local arg
	local -a args
	while (($#)); do
		arg=$1
		shift
		if $WITH_REPETITION; then
			"${FUNCNAME[0]}" "$max" "$num" "${pre[@]}" "$arg" "$arg" "$@" "${args[@]}"
		else
			"${FUNCNAME[0]}" "$max" "$num" "${pre[@]}" "$arg" "$@" "${args[@]}"
		fi
		args+=("$arg")
	done
}

usage() {
	cat <<EOF
Usage: qqcombination.sh [OPTIONS] [--] ARG1 [ARG2...]

Generate combinations of given arguments.

Options:
	-o string  - outputed elements are seperated using this string, default tabulation
	-l string  - outputed lines are seperated using this string, default newline
	-w         - output elements without repetition, default with repetition
	-h         - print this help and exit

Written by Kamil Cukrowski 2018.
Licensed jointly under MIT License and Beerware License.
EOF
}

ARGS=$(getopt -n "qqcombination.sh" -o "o:l:wh" -- "$@")
eval set -- "$ARGS"
while (($#)); do
	case "$1" in
	-o) OUTSEP="$2"; shift; ;;
	-l) LINESEP="$2"; shift; ;;
	-w) WITH_REPETITION=false; ;;
	-h) usage; exit; ;;
	--) shift; break; ;;
	*) usage; echo; echo "Error parsing '$1' argument." >&2; exit 1; ;;
	esac
	shift
done

if [ "$#" -eq 0 ]; then
	usage;
	echo; echo "Error: No arguments given." >&2
	exit 1;
fi

combination "$#" 0 "$@"

