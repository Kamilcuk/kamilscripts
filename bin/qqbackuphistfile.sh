#!/bin/bash 
# written by Kamil Cukrowski
# under Beerware license
set -euo pipefail

usage() {
	cat <<EOF
Usage:
	$0 file [backupfile] [backuprestorefile]

If file has more lines then backupfile, then
  - copy file to backupfile
If backupfile has more lines then file or if they have same number of lines, but differ in content, then
  - copy file to backuprestorefile
  - append new lines in file compared to backupfile to backupfile
  - copy backupfile to file

backupfile is default equal to '\$file.backuphistfile'
backuprestorefile is default equal to '\$file.restorebackuphistfile'

Written by Kamil Cukrowski. Under Beerware License.
EOF
}

histfile_restore() {
	local orig="$1" save="$2" rest="$3"

	echo "Restoring '$orig' ..."

	if [ -f "$rest" ]; then chmod -v +w "$rest"; fi
	cp -va "$orig" "$rest";
	chmod -v -w "$rest"

	if [ -f "$save" ]; then chmod -v +w "$save"; fi
	diff --unchanged-group-format='' --changed-group-format="%<" -a "$orig" "$save" > "$save.$$"
	cat "$save.$$" >> "$save"
	rm "$save.$$"
	chmod -v -w "$save"

	cp -va "$save" "$orig"
}

histfile_backup() {
	local orig="$1" save="$2"
	if [ -f "$save" ]; then chmod -v +w "$save"; fi
	cp -v "$orig" "$save"
	chmod -v -w "$save"
}

backup_histfile() {
	local orig="$1" save="$2" rest="$3"

	if [ ! -f "$orig" ]; then
		usage; echo "ERROR: '$orig' does not exists!" >&2; exit 1;
	fi

	if [ ! -f "$save" ]; then
		echo "Backupfile '$save' does not exists. Creating..."
		histfile_backup "$@"
		return
	fi	
		
	local origlen savelen
	origlen=$(wc -c <"$orig")
	savelen="$(wc -c <"$save")"

	if   [ "$savelen" -gt "$origlen" ]; then
		echo "'$save' has more lines then '$orig' !"
		histfile_restore "$@"
	elif [ "$savelen" -eq "$origlen" ]; then
		if ! diff -q "$orig" "$save"; then 
			echo "'$orig' and '$save' have same number of lines, but they differ in content!"
			histfile_restore "$@"
		else
			echo "'$orig' and '$save' are equal"
		fi
	else
		echo "'$orig' has $((origlen-savelen)) new lines then '$save'"
		histfile_backup "$@"
	fi
}

if [ $# -lt 1 ]; then usage; exit 1; fi;
orig=$1
save=${2:-$orig.backuphistfile}
rest=${3:-$orig.restorebackuphistfile}

backup_histfile "$orig" "$save" "$rest"


