#!/bin/bash -ue
# written by Kamil Cukrowski
# under Beerware license

restore_bashhistory_UNUSED() {
	local orig save buff
	orig="$1"
	save="$2"
	buff="$(cat $save; cat $orig)"
	cp "$orig" "${orig}.restoreqqbackupbashhistory"
	echo "$buff" > "$orig"
}

restore_bashhistory() {
	local orig save buff
	orig="$1"
	save="$2"
	echo "${FUNCNAME[0]} - trying to restore bashhistory"
	buff="$(set -x; cat "$save"; diff -a "$orig" "$save" | grep -a "^< " | sed 's/^< //')"; 
	( set -x; cp -v "$orig" "${orig}.restoreqqbackupbashhistory"; )
	echo '+ echo "$buff" > '"$orig"
	echo "$buff" > "$orig"
}

# copy a orig=$file to save=${file}.autobackup
# only if save has smaller size then orig file
backup_bashhistory() {
	local orig save origlen savelen

	orig="$1"
	save="${1}.qqbackupbashhistory"
	if [ ! -f "$orig" ]; then
		echo "${FUNCNAME[0]} - ERROR - File $orig does not exists";
		return 
	fi

	origlen=$(wc -c "$orig" | cut -d' ' -f1)
	if test -f "$save"; then
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
	else
		( set -x
			chmod +w "$save"
			/usr/bin/cp -a "$orig" "$save"
			chmod -w "$save"
		)
	fi
}

backup_bashhistory /home/users/kamil/.bash_history
backup_bashhistory /root/.bash_history


