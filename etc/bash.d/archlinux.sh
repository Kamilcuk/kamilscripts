#!/bin/bash

if [[ ! -e /etc/arch-release ]]; then
	return
fi

if ((UID)); then
	alias pacman='sudo pacman'
fi

_archlinux_pacman() {
	local tmp sudo
	sudo=(
		sudo
		--preserve-env=no_proxy,http_proxy,https_proxy,ftp_proxy,rsync_proxy,HTTP_PROXY,HTTPS_PROXY,FTP_PROXY,RSYNC_PROXY
	)
	if hash yay 2>/dev/null; then
		if ((UID == 0)) && id kamil 2>/dev/null >&2; then
			tmp=("${sudo[@]}" -u kamil yay)
		else
			tmp=(yay)
		fi
	elif ((UID != 0)); then
		tmp=("${sudo[@]}" pacman)
	else
		tmp=(pacman)
	fi
	echo "+ ${tmp[*]} $*" >&2
	nice ionice "${tmp[@]}" "$@"
}

p() { _archlinux_pacman "$@"; }
# . alias_complete.sh p pacman
pn() { p --noconfirm "$@"; }
# . alias_complete.sh pn pacman
pupdate() {
	local tmp &&
	tmp=$(pacman -Q | cut -d' ' -f1 | grep '[^ ]*-keyring') &&
	if [[ -n "$tmp" ]]; then
		p --noconfirm -Sy --needed $tmp;
	fi &&
	p --noconfirm -Suy "$@" &&
	pacman_autoremove
}
# . alias_complete.sh pupdate pacman
pacmann() { pacman --noconfirm "$@"; }
# . alias_complete.sh pacmann pacman
yayn() { yay --noconfirm "$@"; }
# . alias_complete.sh yayn yay
pacman_autoremove() {
	local tmp
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

pacman_packages_store() {
	mkdir -p "$HOME"/.cache/pacman_packages
	echo "+ pacman -Qq > "$HOME"/.cache/pacman_packages/pkglist-$(date +%Y-%m-%dT%H:%M:%S).txt"
	pacman -Qq > "$HOME"/.cache/pacman_packages/pkglist-$(date +%Y-%m-%dT%H:%M:%S).txt
}
pacman_packages_restore() {
	if test -z "$1"; then
		echo "Ta komenda robi to:"
		echo 'pacman -Rsu $(comm -23 <(pacman -Qq|sort) <(sort $1))'
		echo ' lista pakietów została zapisana w katalogu /root/pkglist-datacostam.txt'
	else
		if [[ ! -r "$1" && -r "$HOME"/.cache/pacman_packages/"$1" ]]; then
			set -- "$HOME"/.cache/pacman_packages/"$1"
		fi
		if [[ ! -r "$1" ]]; then
			echo "File $1 doesn't exists" >&2
			return 2
		fi
		pacman -Rsu $(comm -23 <(pacman -Qq | sort) <(sort "$1"))
	fi
}
_pacman_packages_restore_complete() {
	# https://stackoverflow.com/questions/2805412/bash-completion-for-maven-escapes-colon/12495727#12495727
	COMPREPLY=()
	if ((COMP_CWORD != 1)); then return; fi
	local cur
	_get_comp_words_by_ref -n : cur
	if [[ -d "$HOME"/.cache/pacman_packages ]]; then
		COMPREPLY=($(compgen -W "$(
			find "$HOME"/.cache/pacman_packages -maxdepth 1 -mindepth 1 -type f -printf "%f\n"
		)" -- "$cur"))
	fi
	__ltrim_colon_completions "$cur"
}
complete -o default -F _pacman_packages_restore_complete pacman_packages_restore





