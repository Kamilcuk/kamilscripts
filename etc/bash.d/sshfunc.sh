#!/bin/bash

sshrfunc() {
	local l_script="" l_args l_help='
Usage: sshrfunc [options] [--] user@remote func [args...]

Run a commandon the remote by dynamically creating a bash script
to execute.

Options
	-f <func>	Export the function.
	-p <var>	Export the variable to remote.
	-x	Add set -x
	-e	Add set -euo pipefail
	-h --help	Print this help and exit.

Example:
	$ func2() { ls; }
	$ func() { cd "$dir"; func2; }
	$ dir=/tmp
	$ sshrfunc -x -p dir -f func2 kamil@server func
	+ func
	+ cd /tmp
	+ func2
	+ ls

Written by Kamil Cukrowski 2022
'
	l_args=$(getopt -n sshrfunc -o f:v:xh -l help -- "$@")
	eval "set -- $l_args"
	while (($#)); do
		case "$1" in
		-f) l_script+="$(declare -f "$2");"; shift; ;;
		-p) l_script+="$(declare -p "$2");"; shift; ;;
		-x) l_postscript+="set -x;"; ;;
		-e) l_postscript+="set -euo pipefail;"; ;;
		-h|--help) echo "$l_help" >&2; return 2; ;;
		--) shift; break; ;;
		esac
		shift
	done
	if (($# != 2)); then
		echo "$l_help" >&2
		return 2
	fi
	l_script+="$(declare -f "$2"); set --$(printf " %q" "${@:2}"); exec 2>&1; $l_postscript;"' "$@"'
	l_script="$(printf "%q " bash -c "$l_script")"
	ssh "$1" "$l_script"
}


	

