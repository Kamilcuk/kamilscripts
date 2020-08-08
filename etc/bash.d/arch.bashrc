#!/bin/bash

if [[ ! -e /etc/arch-release ]]; then
	return
fi

if ((UID)); then
	alias pacman='sudo pacman'
fi

_archlinux_pacman() {
	local tmp
	if hash yay 2>/dev/null; then
		tmp="yay"
	elif ((UID)); then
		tmp="sudo pacman"
	else
		tmp="pacman"
	fi
	if [ -z "${_ARCHLINUX_PACMAN_QUIET:-}" ]; then
		echo "+" $tmp "$@"
	fi
	nice ionice $tmp "$@"
}

p() { _archlinux_pacman "$@"; }
. alias_complete.sh p pacman
pn() { p --noconfirm "$@"; }
. alias_complete.sh pn pacman
pupdate() { 
	local tmp &&
	tmp=$(pacman -Q | cut -d' ' -f1 | grep '[^ ]*-keyring') &&
	if [[ -n "$tmp" ]]; then
		p --noconfirm -Sy --needed $tmp;
	fi &&
	p --noconfirm -Suy "$@" &&
	pacman_autoremove
}
. alias_complete.sh pupdate pacman
pacmann() { pacman --noconfirm "$@"; }
. alias_complete.sh pacmann pacman
yayn() { yay --noconfirm "$@"; }
. alias_complete.sh yayn yay
pacman_autoremove() {
	while tmp=$(pacman --query --deps --unrequired --quiet) && [[ -n "$tmp" ]]; do
		p --noconfirm --R $tmp
	done
}


,pacman_list_packages_by_size() {
	pacman -Qii | 
	awk -F: '/^Name *:/{n=$2} /^Installed Size *:/{print n, $2}' |
	awk '{print $2 gensub("B$", "", "g", $3), $1, $2 $3 }' |
	numfmt --field 1 --from=auto |
	sort -k1n
}

,paccheck() {
	local name failed mtree md5sum_files md5sum_dirs failed
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
	return "$failed"
}

