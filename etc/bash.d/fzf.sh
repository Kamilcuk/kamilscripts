#!/usr/bin/env bash


if hash -v fzf-share 2>/dev/null; then
	. "$(fzf-share)/key-bindings.bash"
	. "$(fzf-share)/completion.bash"
else
	for i in \
		/usr/share/fzf/shell/ \
		/usr/share/fzf/ \
		/usr/share/doc/fzf/examples \
	; do
		if [[ -r "$i"/key-bindings.bash ]]; then
			. "$i"/key-bindings.bash
			if [[ -r "$i"/completion.bash ]]; then
				. "$i"/completion.bash
			fi
			break
		fi
	done
	unset i
fi

