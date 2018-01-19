#!/bin/bash
set -euo pipefail

usage() {
	cat <<EOF
Usage:
	$0 testdeploy - will print what will do when deploying
	$0 deploy

Script unfinished, should be used as guide.

Written by Kamil Cukrowski. All rights reserved.
EOF
}

log() { echo "$@"; }


addline() {
	local file line
	file=$1
	line=$2
	if ! grep -x -q "$line" "$file"; then
		log "Apending line '$line' to file '$file'."
		if $NOTEST; then echo "$line" >> "$file"; fi
	fi
}

case "${1:-unknown}" in
testdeploy)
	# somethign
	NOTEST=false
	;&
deploy)
	: ${NOTEST:=true}
	addline /etc/pacman.conf "Include = /usr/lib/kamil-scripts/pacman.d/best_unofficial_repos.conf"
	;;
*)
	usage
	echo "Unknown mode: '$1'"
	;;
esac


