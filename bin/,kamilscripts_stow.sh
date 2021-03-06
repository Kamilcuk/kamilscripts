#!/bin/bash
set -euo pipefail
shopt -s extglob

name=$(basename "$0")
dir="$(git rev-parse --show-toplevel)"
cd "$dir"

usage() {
	cat <<EOF
Usage: $name [options] <mode>

Options:
  -h --help    Print this text and exit
  -f --force   Overwrite files
  -k --ok      Actually do changes

Modes:
  r restow u update
  s stow i install
  d delete uninstall

EOF
}

log() {
	echo "$name:" "$@" >&2
}

fatal() {
	echo "ERROR:" "$@" >&2
	exit 2
}

run() {
	log "+" "$@" >&2
	"$@"
}

# main ##############################################################################

args=$(getopt -n "$name" -o hfk -l help,force,ok -- "$@")
eval set -- "$args"
g_dryrun=1
g_stowargs=()
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-f|--force) g_stowargs+=(--override='.*'); ;;
	-k|--ok) g_dryrun=0; ;;
	--) shift; break; ;;
	esac
	shift
done
if ((g_dryrun)); then
	log "Dry run. Add --ok to actually run"
	g_stowargs+=(-n)
fi

if (($#==0)); then usage; fatal "Missing argument"; exit 1; fi
case "$1" in
r|restow|u|update)   g_stowargs+=(restow) ;;
s|stow|i|install)    g_stowargs+=(stow) ;;
d|delete|uninstall)  g_stowargs+=(delete); ;;
*) echo "Unknown mode: $1" >&2; ;;
esac

run "$dir"/bin/rstow "${g_stowargs[@]}" "$dir/stow"
