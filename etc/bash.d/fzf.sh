#!/usr/bin/env bash
# shellcheck disable=1091

if [[ $- != *i* ]]; then return; fi

if hash fzf-share 2>/dev/null; then
	_i=$(fzf-share)
	if [[ -r "$_i"/key-bindings.bash ]]; then
		. "$_i"/key-bindings.bash
		if [[ -r "$_i"/completion.bash ]]; then
			. "$_i"/completion.bash
		fi
	fi
	unset _i
else
	for _i in \
		/usr/share/fzf/shell/ \
		/usr/share/fzf/ \
		/usr/share/doc/fzf/examples \
	; do
		if [[ -r "$_i"/key-bindings.bash ]]; then
			. "$_i"/key-bindings.bash
			if [[ -r "$_i"/completion.bash ]]; then
				. "$_i"/completion.bash
			fi
			break
		fi
	done
	unset _i
fi

