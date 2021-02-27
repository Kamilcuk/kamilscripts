#!/bin/bash
set -euo pipefail

. "$(dirname "$0")"/.funcs.sh
to_ssh() {
	sed_remote_to_ssh -i .gitmodules
}
to_https() {
	sed_remote_to_https -i .gitmodules
}
detect() {
	sed_remote_detect .gitmodules
}
syncme() {
	diff --old-line-format=$'- %l\n' --new-line-format=$'+ %l\n' --old-group-format='%<' --new-group-format='%>' --changed-group-format='%<%>' --unchanged-group-format='' <(cat <<<"$tmp") .gitmodules ||:
	git submodule sync
}
usage() {
	cat <<EOF
Usage: $name [https|ssh|detect|auto]
EOF
	exit 1
}

if (($# > 1)); then usage; fi;

tmp=$(cat .gitmodules)
case "${1:-auto}" in
http|https) to_https; syncme; ;;
git|ssh) to_ssh; syncme; ;;
detect) detect; ;;
auto)
	a="$(detect)"; 
	case "$a" in
	https) a=ssh; ;;
	ssh) a=https; ;;
	esac
	echo "to $a"
	"$0" "$a"
	;;
*) usage; ;;
esac


