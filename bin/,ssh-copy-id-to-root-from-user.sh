#!/bin/bash
set -euo pipefail

name=$(basename "$0")

usage() {
	cat <<EOF
Usage: $name sshoptions

Transfers local public key to remote location
to root using sudo.

Example:
	$name kamil@server

All rights reserved
EOF
}

if (($# == 0)); then usage; exit 1; fi

pubkey=$(cat ~/.ssh/id_rsa.pub)
work() {
	authk=/root/.ssh/authorized_keys

	fatal() {
		echo "$name: ERROR: $*" >&2
		exit 1
	}
	if [[ -z "$pubkey" ]]; then 
		fatal "pubkey is missing"
	fi
	typ=$(<<<"$pubkey" awk '{print $1}')
	key=$(<<<"$pubkey" awk '{print $2}')
	desc=$(<<<"$pubkey" sed 's/^[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*//')
	if [[ -z "$typ" ]]; then
		fatal "pubkey is invalid - first column is missing"
	fi
	if [[ -z "$key" ]]; then
		fatal "pubkey is invalid - second column is missing"
	fi
	if [[ -z "$desc" ]]; then
		fatal "pubkey is invalid - description is missing"
	fi

	if [[ -e "$authk" ]] &&
		awk -v typ="$typ" -v key="$key" '$1==typ && $2==key{c=1} END{exit !c}' "$authk"
	then
		echo "$name: Key '$desc' already installed"
	else
		authkdir=$(dirname -- "$authk")
		mkdir -v -p "$authkdir"
		cat >> "$authk" <<<"$pubkey"
		echo "$name: Key '$desc' successfully added"
	fi		
}

( set -x ; ssh "$@" 'sudo -u root bash -s' ) <<EOF
set -euo pipefail
$(declare -p pubkey name)
$(declare -f work)
work
EOF

