#!/bin/bash

get_packages() {
	shopt -s extglob
	echo common
	if [[ -e "$HOSTNAME" ]]; then
		echo "$HOSTNAME"
	fi
	if grep -Eqx 'gucio|(dudek|dzik|jenot|kumak|leszcz|wilga|bocian).cis.gov.pl' <<<"$HOSTNAME" &&
			[[ "$g_mode" == "delete" || "$g_mode" == "restow" ]]; then
		# uninstall it
		echo fix_term_missing_italic

	fi
}
PACKAGES=($(get_packages))

