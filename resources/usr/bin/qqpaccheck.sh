#!/bin/bash
set -euo pipefail

name=$1

failed=0
mtree=$(printf "%s\n" /var/lib/pacman/local/${name}-[0-9]*/mtree | head -n 1)
mtree=$(zcat "$mtree")
if ! md5sum_files=$(echo "$mtree" | grep -v "\./\." | sed -n '/md5digest/s/\.\?\([^\ ]*\) .* md5digest=\([^\ ]*\) .*/\2 \1/p' | md5sum -c -); then
	echo "md5sum failed on files:"
	echo "$md5sum_files" | grep -v ": OK$"
	(( failed++ ))
fi

if ! md5sum_dirs=$(echo "$mtree" | grep -v "\./\." | grep type=dir | sed 's/^\.//' | while read path _; do if [ -d "$path" ]; then echo "$path: OK"; else echo "$path: FAILED"; fi; done;); then
	echo "md5sum failed on dirs"
	echo "$md5sum_dirs" | grep -v ": OK$"
	(( failed++ ))
fi

if (( failed == 0 )); then
	echo "OK"
fi
exit "$failed"

