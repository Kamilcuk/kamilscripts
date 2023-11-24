#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
	return
	# shellcheck disable=2317
	exit
fi

# https://rsapkf.xyz/blog/enabling-italics-vim-tmux
(
	ihas() {
		infocmp "$1" 2>/dev/null >&2
	}
	kcterminfos=${KCDIR:-}/etc/terminfo
	if {
		cd "$kcterminfos" &&
			hash tic &&
			hash infocmp &&
			[ -d "$KCDIR" ] &&
			mkdir -p ~/.terminfo
	} 2>/dev/null >&2; then
		files=()
		for i in *.terminfo; do
			name=${i##*/}
			name=${i%.terminfo}
			file=~/.terminfo/${i:0:1}/$name
			if [[ ! -e "$file" || "$i" -nt "$file" ]] && ! ihas "$name"; then
				files+=("$i")
			fi
		done
		if ((${#files[@]})); then
			tic -x -o ~/.terminfo "${files[@]}"
		fi
	fi
)
