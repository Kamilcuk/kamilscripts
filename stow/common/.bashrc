#!/bin/bash

for i in "${XDG_CONFIG_HOME:-$HOME/.config}/bash.d/"*; do
	if [[ -r "$i" ]]; then
		. "$i"
	fi
done
unset i

