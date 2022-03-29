#!/bin/bash

sshrfunc() {
	local l_script="" l_args l_postscript="" l_sshopts=() l_help='
Usage: sshrfunc [options] [--] user@remote func [args...]

Run a commandon the remote by dynamically creating a bash script
to execute.

Options
	-f <func>	Export the function.
	-p <var>	Export the variable to remote.
	-x	Add set -x
	-e	Add set -euo pipefail
	-o <opts>	Add ssh -o option.
	-h --help	Print this help and exit.

Example:
	$ func2() { ls; }
	$ func() { cd "$dir"; func2; }
	$ dir=/tmp
	$ sshrfunc -x -p dir -f func2 -o Port=22 kamil@server func
	+ func
	+ cd /tmp
	+ func2
	+ ls

Written by Kamil Cukrowski 2022
'
	l_args=$(getopt -n sshrfunc -o f:v:xeh -l help -- "$@")
	eval "set -- $l_args"
	while (($#)); do
		case "$1" in
		-f)
			if ! l_script+="$(declare -f "$2");"; then
				echo "sshrfunc: ERROR: Function $2 is not defined" >&2
				return 1
			fi
			shift
			;;
		-p)
			if ! l_script+="$(declare -p "$2");"; then
				echo "sshrfunc: ERROR: Variable $2 does not exists" >&2
				return 1
			fi
			shift
			;;
		-x) l_postscript+="set -x;"; ;;
		-e) l_postscript+="set -euo pipefail;"; ;;
		-o) l_sshopts+=(-o "$2"); shift; ;;
		-h|--help) echo "$l_help" >&2; return 2; ;;
		--) shift; break; ;;
		*) echo "sshrfunc: Internal error when parsing arguments: $*" >&2; return 3; ;;
		esac
		shift
	done
	if (($# != 2)); then
		echo "$l_help" >&2
		return 2
	fi
	if ! l_script+="$(declare -f "$2");"; then
		echo "sshrfunc: ERROR: Function $2 is not defined" >&2
		return 1
	fi
	l_script+="set --$(printf " %q" "${@:2}"); exec 2>&1; $l_postscript"' "$@"'
	l_script="$(printf "%q " bash -c "$l_script")"
	# shellcheck disable=SC2029
	ssh "${l_sshopts[@]}" "$1" "$l_script"
}


