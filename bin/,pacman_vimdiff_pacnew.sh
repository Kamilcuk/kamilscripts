#!/bin/bash
set -euo pipefail

if (($# != 0)); then
	cat <<EOF
Usage: $(basename "$0")

For each *.pacnew and *.pacsave file
runc vimdiff and then asks two questions.

Written by Kamil Cukrowski
EOF
	exit 1
fi

if [[ "$UID" != 0 ]]; then
	echo "Running with sudo..."
	echo "+" "sudo" "$0" "$@"
	echo
	exec sudo "$0" "$@"
fi

findthem() {
	grep -aEo "[^ ]*\.$1" /var/log/pacman.log |
	sort -u |
	while IFS= read -r line; do
		if [[ -e "$line" ]]; then
			printf "%s\n" "$line"
		fi
	done
}

tmp=$(findthem pacnew) ||:
readarray -t pacnew < <(printf "%s" "$tmp")
tmp=$(findthem pacsave) ||:
readarray -t pacsave < <(printf "%s" "$tmp")

printf "%2d .pacnew files found.\n" "${#pacnew[@]}"
printf "%2d .pacsave files found.\n" "${#pacsave[@]}"
echo

was_pacsave=false
for i in "${pacnew[@]}" "${pacsave[@]}"; do
	if [[ "$i" =~ \.pacsave$ ]] && ! "$was_pacsave"; then
		was_pacsave=true
		echo "Success! There are no *.pacnew files on the system!!!"
		while true; do
			read -r -p "Do you want to continue with *.pacsave files? [yes/no] " ans; echo
			case "$ans" in 
			yes) break; ;;
			no) exit; ;;
			*) echo "Please answer exactly 'yes' or 'no'."; echo; ;;
			esac
		done
	fi
	now="${i%.pac*}"
	new="$i"
	if ! cmp -s "$now" "$new"; then
		cmd=( vimdiff "$now" "$new" )
		echo "+" "${cmd[@]}"
		sleep 1
		"${cmd[@]}"
		read -r -n 1 -p "Edit was successfull? [y/n] " ans; echo
		case "$ans" in [yYtT]) ;; *) exit; ;; esac
	else
		echo "Files $now and $new are the same..."
	fi
	read -r -n 1 -p "Remove $i? [y/n] " ans; echo
	case "$ans" in [yYtT]) rm -I -v "$i";; esac
	echo
done

