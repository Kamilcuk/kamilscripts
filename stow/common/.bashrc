#!/bin/bash

for i in \
		"${XDG_CONFIG_HOME:-$HOME/.config}"/bash.d/*.sh \
		~/.bashrc_*
do
	if [[ -e "$i" ]]; then
		. "$i"
	fi
done
unset i

