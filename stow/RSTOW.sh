#!/bin/bash

shopt -s extglob
PACKAGES=($(
	echo common
	if [[ -e "$HOSTNAME" ]]; then
		echo "$HOSTNAME"
	fi
	case "$HOSTNAME" in gucio|@(dudek|dzik|jenot|kumak|leszcz|wilga|bocian).cis.gov.pl) echo fix_term_missing_italic; ;; esac
) )

