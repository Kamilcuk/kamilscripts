#!/bin/bash

if [[ ! -e /etc/arch-release ]]; then
	return
fi

if ((UID)); then
	alias pacman='sudo pacman'
fi

_archlinux_pacman() {
	local tmp sudo envs i IFS
	envs=()
	sudo=( sudo )
	for i in \
		no_proxy http_proxy https_proxy ftp_proxy rsync_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY
	do
		if [[ -n "${!i}" ]]; then
			envs+=("$i")
		fi
	done
	if ((${#envs[@]})); then
		sudo+=( "--preserve-env=$(IFS=, ; echo "${envs[*]}")")
	fi
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
	if [[ " $* " =~ " -S " ]]; then
		tmp+=(--needed)
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
		# shellcheck disable=2086
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
		# shellcheck disable=2086
		p --noconfirm -R $tmp
	done
}




