#!/bin/bash
set -euo pipefail

to_ssh() {
	sed -E 's~^(\s*url\s*=\s*)https://github.com/[kK]amilcuk/~\1git@github.com:kamilcuk/~' -i .gitmodules
}
to_https() {
	sed -E 's~^(\s*url\s*=\s*)git@github.com:[kK]amilcuk/~\1https://github.com/kamilcuk/~' -i .gitmodules
}
detect() {
	sed -E '
		\~^\s*url\s*=\s*https://github.com/[kK]amilcuk~{ s/.*/https/; q }
		\~^\s*url\s*=\s*git@github.com:[kK]amilcuk/~{ s/.*/ssh/; q }
		d
	' .gitmodules
}
syncme() {
	diff --old-line-format=$'- %l\n' --new-line-format=$'+ %l\n' --old-group-format='%<' --new-group-format='%>' --changed-group-format='%<%>' --unchanged-group-format='' <(cat <<<"$tmp") .gitmodules ||:
	git submodule sync
}
usage() {
	cat <<EOF
Usage: $(basename "$0") [https|ssh|detect|auto]
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


