#!/bin/bash
set -euo pipefail

name=$(basename -- "$0")

dir_is_empty() {
	[[ -z "$(ls -A "$1" ||:)" ]]
}

fatal() {
	echo "$name: ERROR: $*" >&2
	exit 1
}

log() {
	echo ">>- $name: $*" >&2
}

run() {
	echo "+" "$*" >&2
	"$@"
}

###############################################################################

dest=$1

mkdir -p "$dest"
if ! dir_is_empty "$dest"; then
	fatal "Error: $dest is not empty"
fi
dest=$(readlink -f "$dest")
cd "$dest"

mirror=http://dl-cdn.alpinelinux.org/alpine
branch=edge
repourl="$mirror/$branch"/main/x86_64

log "Getting apk-tools-static version"
version=$(
	run curl -sS "$repourl"/APKINDEX.tar.gz |
	tar -xzvf - APKINDEX -O |
	awk -v RS='\n\n' '/\nP:apk-tools-static\n/' |
	awk -F: '$1=="V"{print $2}'
)
if [[ -z "$version" ]]; then fatal "Problem getting apk-tools-static version"; fi

log "Downloading apk-tools-static utility"
run curl -sS "$repourl"/apk-tools-static-"$version".apk | tar -xzvf - -O sbin/apk.static > apk.static
chmod -v +x apk.static

log "Installing alpine"
run sudo ./apk.static -X "$mirror/$branch/main" -U --allow-untrusted -p "$dest" --initdb add alpine-base

log "Setuping apk repositories"
run sudo tee -a "$dest"/etc/apk/repositories >/dev/null <<EOF
# Provisioned by $name script
$mirror/$branch/main
$mirror/$branch/community
EOF

log "Cleanup"
rm -v apk.static

log "Installation complete"

