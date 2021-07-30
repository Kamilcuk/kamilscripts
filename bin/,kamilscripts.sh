#!/bin/bash
set -euo pipefail
shopt -s extglob

name=$(basename "$0")
dir="$(cd "$(dirname "$0")" && git rev-parse --show-toplevel)"
export PATH="$dir/bin:$PATH"

usage() {
	cat <<EOF
Usage: $name [options] <mode>

Options:
  -h --help    Print this text and exit
  -f --force   Overwrite files
  -k --ok      Actually do changes

Modes:
  u update r restow
  i install s stow
  d delete uninstall
  add <file>

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

install_chezmoi() {
	if [ ! "$(command -v chezmoi)" ]; then
		bin_dir="$HOME/.local/bin"
		chezmoi="$bin_dir/chezmoi"
		if [[ -e /etc/arch-release ]]; then
			pacman -S chezmoi
		fi ||
		if [ "$(command -v curl)" ]; then
			sh -c "$(curl -fsLS https://git.io/chezmoi)" -- -b "$bin_dir"
		elif [ "$(command -v wget)" ]; then
			sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
		else
			fatal "To install chezmoi, you must have curl or wget installed."
		fi
	else
		chezmoi=chezmoi
	fi
}

# main ##############################################################################


args=$(getopt -n "$name" -o hfk -l help,force,ok -- "$@")
eval "set -- $args"
g_dryrun=1
g_addargs=()
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-f|--force) g_addargs+=(--force); ;;
	-k|--ok) g_dryrun=0; ;;
	--) shift; break; ;;
	esac
	shift
done
install_chezmoi

if (($#==0)); then usage; fatal "Missing argument"; exit 1; fi
case "$1" in
r|restow|u|update|s|stow|i|install) g_addargs+=(apply) ;;
add) fatal "todo"; ;;
d|delete|uninstall|*)
	fatal "Unknown mode: $1"; ;;
esac
if ((g_dryrun)); then
	log "Dry run. Add --ok to actually run"
	g_addargs+=(-n)
fi

# run chezmoi upgrade ||:
run chezmoi "${g_addargs[@]}" -v -S "$dir/chezmoi"
