#!/bin/bash

if [ ! -e /etc/arch-release ]; then
	return
fi

if [ "$UID" -ne 0 ]; then
	alias pacman='sudo pacman'
fi

_archlinux_pacman() {
	local tmp
	if hash yay 2>/dev/null; then
		tmp="yay"
	elif [ "$UID" -ne 0 ]; then
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
pupdate() { p --noconfirm -Suy "$@"; }
eval "$(alias_complete.sh pupdate pacman)"
pacmann() { pacman --noconfirm "$@"; }
eval "$(alias_complete.sh pacmann pacman)"
yayn() { yay --noconfirm "$@"; }
eval "$(alias_complete.sh yayn yay)"

