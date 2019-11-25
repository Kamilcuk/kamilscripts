#!/bin/bash

if [ ! -e /etc/arch-release ]; then
	return
fi

if [ "$UID" -ne 0 ]; then
	alias pacman='sudo pacman'
fi

tmp=""
if hash yay 2>/dev/null; then
	tmp=(yay)
elif [ "$UID" -ne 0 ]; then
	tmp=(sudo pacman)
else
	tmp=(pacman)
fi

p() { nice ionice "$tmp" "$@"; }
eval "$(alias_complete.sh p "$tmp")"
pn() { p --noconfirm "$@"; }
eval "$(alias_complete.sh pn "$tmp")"
pupdate() { p --noconfirm -Suy "$@"; }
eval "$(alias_complete.sh pupdate "$tmp")"
eval "$(alias_complete.sh -a pacmann pacman --noconfirm)"
eval "$(alias_complete.sh -a yayn yay --noconfirm)"

unset tmp

