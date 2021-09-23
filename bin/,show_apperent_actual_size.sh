#!/bin/bash

name=${BASH_SOURCE[0]##*/}
usage() {
cat <<EOF 
Usage: $name [options] paths...

Compare actual and apparent size of files and directories.
Internally calls du -s and du -s --apparent-size
on supplied arguments.

Options:
   -h  Print this help and exit.

Written by Kamil Cukrowski
Licensed jointly under MIT License and Beerware License.
EOF
}

args=$(getopt -n "$name" -o h -- "$@")
eval set -- "$args"
while (($#)); do
	case "$1" in
	-h) usage; exit; ;;
	--) shift; break; ;;
	esac
	shift
done

if ((!$#)); then
	echo "$name: Missing arguments, see $name -h" >&2
	exit 2
fi

{
	du -s "$@"
	echo
	du -s --apparent-size "$@"
} |
awk '
!cnt { arr[NR]=$1 }
cnt {
	s=arr[NR-cnt]
	printf "%.2f%% %s %s ", s / $1 * 100, s, $1
	$1=""
	print
}
/^$/{ cnt=NR }
' |
numfmt --field 2,3 --to=iec |
awk '
BEGIN { printf "%7s %5s %5s  %s\n", "Percent", "Comp", "Real", "Name" }
{
	printf "%7s %5s %5s  ", $1, $2, $3;
	sub(/^[^ ]* *[^ ]* *[^ ]* */, "")
	print
}'

