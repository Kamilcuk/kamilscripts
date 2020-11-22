#!/bin/bash
set -euo pipefail

name=$(basename "$0")
usage() {
	cat <<EOF
Usage: $name [--ok]
	
Remove the stuff from .git/modules not currently used

EOF
}
fatal() { echo "$(basename "$0"): ERROR:" "$@"; }

if ! dir=$(timeout 1 git rev-parse --show-toplevel); then
	fatal "Could not find git dir"
fi
cd "$dir"

ok=false
if (($#)); then
	if [[ "$1" == "--ok" ]]; then
		ok=true
	else
		usage
		exit 1
	fi
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
run() {
	if "$ok"; then
		echo "+" "$@"; 
		"$@";
	else
		echo "?+" "$@"
	fi
}

if [[ ! -e ".git/modules" ]]; then
	fatal ".git/modules does not exists"
fi

git submodule |	awk '{print $2}' | (
	cd .git/modules;
	while IFS= read -r line; do
		run mkdir -p "$tmp"/"$(dirname "$line")"
		run mv "$line" "$tmp"/"$line"
	done
);
run rm -rf .git/modules/*
run mv "$tmp"/* .git/modules/

