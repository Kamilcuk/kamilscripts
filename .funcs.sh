#!/bin/bash
set -euo pipefail

name=$(basename "$0")
#dir=$(dirname "$0")

exec 10>&1
log() {
	echo "$name: $*" >&10
}
fatal() {
	echo "$name: ERROR: $*" >&2
	exit 2
}
runlog() {
	log "+ $*"
	"$@"
}

sed_remote_to_ssh() {
	sed -E 's~^(\s*url\s*=\s*)https://github.com/[kK]amilcuk/~\1git@github.com:kamilcuk/~' "$@"
}
sed_remote_to_https() {
	sed -E 's~^(\s*url\s*=\s*)git@github.com:[kK]amilcuk/~\1https://github.com/kamilcuk/~' "$@"
}
sed_remote_detect() {
	sed -E '
		\~^\s*url\s*=\s*https://github.com/[kK]amilcuk~{ s/.*/https/; q }
		\~^\s*url\s*=\s*git@github.com:[kK]amilcuk/~{ s/.*/ssh/; q }
		d
	' "$@"
}

git_remote_get-url() {
	git remote -v show | awk 'NR==1{print $2}'
}

git_autostash_supported() {
	git --version | awk '{exit !(0+$3>2.6)}'
}


