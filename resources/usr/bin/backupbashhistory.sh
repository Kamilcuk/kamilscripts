#!/bin/bash
# written by Kamil Cukrowski
# under Beerware license
set -euo pipefail

RESTORE_EXT=${RESTORE_EXT:-restorebackupbashhistory}
BACKUP_EXT=${BACKUP_EXT:-backupbashhistory}

# Functions #######################################################

restore_bashhistory() {
	local orig save buff
	orig="$1"
	save="$2"
	echo "${FUNCNAME[0]} - trying to restore bashhistory"
	buff="$(cat "$save"; diff -a "$orig" "$save" | grep -a "^< " | sed 's/^< //')"; 
	cp -v "$orig" "${orig}.${RESTORE_EXT}"
	echo '+ echo "$buff" > '"$orig"
	echo "$buff" > "$orig"
}

backup_bashhistory() {
	local orig save origlen savelen

	orig="$1"
	save="${1}.${BACKUP_EXT}"
	if [ ! -f "$orig" ]; then
		echo "${FUNCNAME[0]} - ERROR - File $orig does not exists" >&2;
		return 
	fi

	origlen=$(wc -c "$orig" | cut -d' ' -f1)
	if [ -f "$save" ]; then
		savelen="$(wc -c "$save" |  cut -d' ' -f1)"
	else
		savelen=0
	fi

	if   [ "$savelen" -gt "$origlen" ]; then
		echo "${FUNCNAME[0]} - ERROR - File $save is bigger then $orig"
		echo "${FUNCNAME[0]} - Probably some of bash_history in $orig has been deleted..."
		restore_bashhistory "$orig" "$save"
	elif [ "$savelen" -eq "$origlen" ]; then
		if ! diff -q "$orig" "$save"; then 
			echo "${FUNCNAME[0]} - ERROR - $orig and $save have same length but differ";
			echo "${FUNCNAME[0]} - Probably some of bash_history in $orig has been deleted..."
			restore_bashhistory "$orig" "$save"
		fi
	fi

	if [ -e "$save" ]; then chmod -v +w "$save"; fi
	cp -v -a "$orig" "$save"
	chmod -v -w "$save"
}

usage() { 
	cat <<EOF
Usage: backupbashhistory.sh file [file ...]

Primary usage of script is to backup bash history so it does not get deleted.

For every file:
If backupfile is smaller then file, then 
	script backups file into backupfile on every run.
if not, that means
	that file was truncated somehow (by HISTORYSIZE probably in bash).
	Content of the file is backuped into restorebackupfile.
	A diff is calculated between backupfile and file and old lines are propended to file.
	Then file is backuped to backupfile.
backupfile is named \$file.\$BACKUP_EXT
restorebackupfile is named \$file.\$RESTORE_EXT

Environment variables:
	BACKUP_EXT   - manipulate backup file extension
	RESTORE_EXT  - manipulate backup file extension while restoring file

Written by Kamil Cukrowkis 2017
Under Beerware license.
EOF
}

# Main #########################################################

if [ $# -eq 0 ]; then
	usage;
	exit 1;
fi

for file; do
	backup_bashhistory "$file"
done
