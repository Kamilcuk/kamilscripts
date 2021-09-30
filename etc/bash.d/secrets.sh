#!/bin/bash

for i in "${BASH_SOURCE[0]%/*}"/../../secrets/bash.d/*.sh; do
	if [[ -r "$i" ]]; then
		. "$i"
	fi
done
unset i
