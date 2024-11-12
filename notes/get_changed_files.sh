#!/bin/bash
set -ueo pipefail

# functions ##############################3

usage() {
	cat <<EOF
Usage:
	$0 <ONE OPTION>

Options:
	-P 	- run paccheck, show filenames between installed files and repo
	-D	- show diff of files returned by -P
	-O  - overwrite files returned by -P in filesystem by repo - not implemented
	-I 	- overwrite files returned by -P in repo by filesystem - not implemented

	-p	- show all filenames differing between filesystem and repo
	-d	- show diff of files returned by -p
	-o  - overwrite files returned by -p in filesystem by repo - not implemented
	-i 	- overwrite files returned by -p in repo by filesystem - not implemented

	-h 	- show this help and exit

Written by Kamil Cukrowski (c) 2017. Licensed under GPL-3.0.
EOF
}

printDiff() { 
	local f="$1"
	if [ ! -e "/${f}" ]; then
		echo "/${f}: No such file."
		return
	fi
	if ! cmp "/${f}" "$uniondir/${f}" >/dev/null 2>&1; then
		diff -u --color -- "$uniondir/${f}" "/${f}" || true
	fi
}

printDiffFilename() { 
	local f="$1"
	if [ ! -e "/${f}" ]; then
		echo "/${f}: No such file."
		return
	fi
	if ! cmp "/${f}" "$uniondir/${f}" >/dev/null 2>&1; then
		echo "$f"
	fi
}

main_case() {
case "${1:--h}" in
-P)
	paccheck --md5sum --quiet kamil-scripts | awk '{print $2}' | sed -e "s/^'//" -e "s/'$//"
	;;
-D)
	for f in $(main_case -P); do
		printDiff "$f"
	done
	;;

-p)
	files=$(cd "$(readlink -f "$uniondir")" && find . -type f | sed 's/^\.\///g' )
	for f in $files; do
		printDiffFilename "$f"
	done
	;;
-d)
	for f in $(main_case -p); do
     	printDiff "$f"
    done
	;;

*)
	usage; exit 1;
	;;
esac
}

# main ##############################################

#gitdir=$(GIT_DISCOVERY_ACROSS_FILESYSTEM=yes git rev-parse --show-toplevel)
#gitdir="$(dirname $(dirname $(readlink -f "$0")))"
uniondir=../resources/
echo


main_case "$@"
