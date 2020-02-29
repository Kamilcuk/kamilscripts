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
eval "$(alias_complete.sh p pacman)"
pn() { p --noconfirm "$@"; }
eval "$(alias_complete.sh pn pacman)"
pupdate() { 
	local tmp
	tmp=$(pacman -Q | cut -d' ' -f1 | grep '[^ ]*-keyring')
	if [[ -n "$tmp" ]]; then
		p --noconfirm -Sy --needed $tmp;
	fi
	p --noconfirm -Suy "$@"
	tmp=$(pacman -Qdtq)
	if [[ -n "$tmp" ]]; then 
		p --noconfirm -R $tmp
	fi
}
eval "$(alias_complete.sh pupdate pacman)"
pacmann() { pacman --noconfirm "$@"; }
eval "$(alias_complete.sh pacmann pacman)"
yayn() { yay --noconfirm "$@"; }
eval "$(alias_complete.sh yayn yay)"

