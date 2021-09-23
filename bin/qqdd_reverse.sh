#!/bin/bash
set -euo pipefail

usage() {
	cat <<EOF
Usgae:
	$0 if=.. of=.. count=100 seek=2 skip=1

A simple dd wrapper using bash to allow reverse dd copy.

Usage examples:
Imagine you have a partition /dev/sda1 of 10M size formatted
with YourFavoriteFilesystemTM and you want to
move the start of this partition 1M to the right.
What you do, is to create a partition /dev/sda1 of 11M size. 
(i.e. partition size + size you want to move the partition).
Then you run:
	$0 if=/dev/sda1 of=/dev/sda1 count=10 bs=1M seek=1
This will seek 10M data in /dev/sda1 of 1M to the right.
Then you run fdisk again, and recreate /dev/sda1 partition, 
but seeked 1M to the right.

Written by Kamil Cukrowski. Jointly under Beerware and MIT License.
EOF
}

if [ $# -eq 0 ]; then usage; exit 1; fi;

skip=0
args=()
for arg; do
	IFS='=' read -r name val <<<"$arg"
	case $name in
	count)
		count=$val
		;;
	seek)
		seek=$val
		;;
	skip)
		skip=$val
		;;
	*)
		# shellcheck disable=2206
		args+=($arg)
	esac
done

for i in count seek skip; do
	if eval [ -z "\"\${$i:-}\"" ]; then
		echo "ERROR: you must specify the option $i= for this file to work" >&2
		exit 1
	fi
done

count=$((count-1))
tmp=$(seq $count -1 0)
for i in $tmp; do
	(
	set -x; 
	dd "${args[@]}" count=1 skip=$((i+skip)) seek=$((i+skip+seek))
	)
done

