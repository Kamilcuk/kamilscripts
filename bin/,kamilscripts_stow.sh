#!/bin/bash
set -euo pipefail

name=$(basename "$0")
dir="$(readlink -f "$(dirname "$(readlink -f "$0")")"/../stow)"

usage() {
	cat <<EOF
Usage: $name [options] <mode>

Options:
  -h --help  Pritn this text and exit
  -k --ok    Actually do changes

Modes:
  install
  uninstall

EOF
}

args=$(getopt -n "$name" -o hk -l help,ok -- "$@")
eval set -- "$args"
ok=false
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-k|--ok) ok=true; ;;
	--) shift; break; ;;
	esac
	shift
done

stowargs=()
if ! "$ok"; then
	echo "Dry run. Add --ok to actually run"
	stowargs+=(-n)
fi

export PATH="$PATH:$(dirname "$BASH_SOURCE")/../bin"
if ! hash qstow 2>/dev/null; then
	echo "ERROR: qstow not found" >&2
fi

run() {
	echo "+" "$@"
	"$@"
}

s() {
	local flags
	flags=("${stowargs[@]}" "$@" common)
	if [[ -d "$dir/$HOSTNAME" ]]; then flags+=("$HOSTNAME"); fi
	for i in /usr/lib/kamilscripts /lib/kamilscripts; do
		if [[ ! -e "$i" ]]; then
			flags+=("noinstall")
			break
		fi
	done
	run qstow --ignore '^.*\.gitkeep$' -v -t "$HOME" -d "$dir" "${flags[@]}"
}

if (($#==0)); then usage; exit 1; fi
case "$1" in
i*)    s -R; if "$ok"; then ( set -x && cd "$dir" && git submodule update --recursive --init; ); fi; ;;
u*)    s -D ;;
*) echo "Unknown mode: $1" >&2; ;;
esac

