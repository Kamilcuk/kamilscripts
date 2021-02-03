#!/bin/bash
set -euo pipefail

name=$(basename -- "$0")
usage() {
	cat <<EOF
Usage: $name <destination_directory>

Downloads and installs GNU stow into destination directory.

Written by Kamil Cukrowski
EOF
}
fatal() {
	echo "$name: ERROR: $*" >&2
	exit 2
}
quit() {
	echo "$name: $*" >&2
	exit
}
is_stow() {
	[[ -x "$1" ]] && "$1" --version 2>/dev/null >&2
}
run() {
	echo "+" "$@"
	"$@"
}

args=$(getopt -n "$name" -o f -- "$@")
eval set -- "$args"
g_force=false
while (($#)); do
	case "$1" in
	-f) g_force=true; ;;
	*) shift; break; ;;
	esac
	shift
done

if (($# == 0)); then usage; fatal "Missing argument"; fi
if (($# != 1)); then fatal "Too many arguments"; fi

if ! "$g_force" && hash stow 2>/dev/null >&2; then
	quit "System stow detected - bailing out"
fi
d="$1"
if is_stow "$d"/stow; then
	if ! "$g_force"; then
		quit "Stow already installed in $d"
	fi
	run rm -r "$d"
fi
mkdir -p "$d"/src
cd "$d"/src
run wget https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz.sig
run tar xaf stow-latest.tar.gz --strip-components=1 -C .
run ./configure --quiet --prefix="$d" --with-pmdir="$d" --bindir="$d"
run make install MAKEINFO=true
cd "$d"
#run rm -r "$d"/src/ "$d"/share/
if ! is_stow "$d"/stow; then
	fatal "Problem installing stow"
fi
quit "$("$d"/stow --version) installed to $d/stow"

