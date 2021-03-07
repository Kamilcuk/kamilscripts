#!/bin/bash

shopt -s extglob
PACKAGES=($(
	echo common
	if [[ -e "$HOSTNAME" ]]; then
		echo "$HOSTNAME"
	fi
	if grep -Eqx 'gucio|(dudek|dzik|jenot|kumak|leszcz|wilga|bocian).cis.gov.pl' <<<"$HOSTNAME"; then
		echo fix_term_missing_italic
	fi
) )

