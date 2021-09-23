#!/bin/bash

get_packages() {
	shopt -s extglob
	echo common
	if [[ -e "$HOSTNAME" ]]; then
		echo "$HOSTNAME"
	fi
	# shellcheck disable=2154
	if grep -Eqx 'gucio|(dudek|dzik|jenot|kumak|leszcz|wilga|bocian).cis.gov.pl' <<<"$HOSTNAME" &&
			[[ "$g_mode" == "delete" || "$g_mode" == "restow" ]]; then
		# uninstall it
		echo fix_term_missing_italic

	fi
}
# shellcheck disable=2034,2207
PACKAGES=($(get_packages))

