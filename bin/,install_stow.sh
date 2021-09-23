#!/bin/bash
set -euo pipefail

name=$(basename -- "$0")

usage() {
	cat <<EOF
Usage: $name [options] <destination_directory>

Options:
  -f   Force.
  -v   Be verbose - print compilation commands.
  --unittest

Downloads and installs GNU stow into destination directory.

Written by Kamil Cukrowski
EOF
}

notice() {
	echo "$name:" "$@"
}

log() {
	if "$g_verbose"; then
		notice "$@"
	fi
}

fatal() {
	notice "ERROR:" "$@" >&2
	exit 1
}

quit() {
	if ! "$g_quiet"; then
		notice "$@"
	fi
	exit
}

trap_err() {
	echo "errexit on line $(caller)" >&2
}

trap 'trap_err' ERR

unittest() {
	tmpd="/tmp/install_stow_unittest.$$"
	readonly tmpd
	trap 'rm -fr "$tmpd"' EXIT

	local tmp
	set -x

	tmp=$("$0" -f "$tmpd"/stow2)
	tmp=$(if [[ -z "$tmp" ]]; then echo 0; else wc -l <<<"$tmp"; fi)
	[[ "$tmp" -lt 2 ]]
	"$tmpd"/stow2/stow --version >/dev/null

	tmp=$("$0" -fq "$tmpd"/stow1)
	[[ -z "$tmp" ]]
	"$tmpd"/stow1/stow --version >/dev/null

	mkdir -p "$tmpd"/stow3/preserveme
	touch "$tmpd"/stow3/preserveme/fdsma
	touch "$tmpd"/stow3/fdsma
	tmp=$("$0" -fv "$tmpd"/stow3)
	tmp=$(wc -l <<<"$tmp")
	[[ "$tmp" -gt 2 ]]
	[[ -d "$tmpd"/stow3/preserveme ]]
	[[ -f "$tmpd"/stow3/preserveme/fdsma ]]
	[[ -f "$tmpd"/stow3/fdsma ]]
	"$tmpd"/stow3/stow --version >/dev/null

	export PATH=$PATH:"$tmpd"/stow3
	tmp=$("$0" -v "$tmpd"/stow3)
	grep -q 'detected' <<<"$tmp"
	tmp=$(wc -l <<<"$tmp")
	[[ "$tmp" -lt 2 ]]

	echo "UNITTEST SUCCESS"
}

# shellcheck disable=2086,2116
is_stow() {
	[[ -x "$1" ]] &&
	g_version=$("$1" --version) 2>/dev/null &&
	# remove newlines and spaces
	g_version=$(echo $g_version)
}

run() {
	local tmp="" ret=0
	log "+" "$@"
	if "$g_verbose"; then
		"$@" || ret=$?
	else
		tmp=$("$@" 2>&1) || ret=$?
	fi
	if ((ret)); then
		if [[ -n "$tmp" ]]; then
			cat <<<"$tmp"
		fi
		fatal "Command failed:" "$@"
	fi
}

###############################################################################

args=$(getopt -n "$name" -o fvq -l unittest -- "$@")
eval set -- "$args"
g_force=false
g_verbose=false
g_quiet=false
while (($#)); do
	case "$1" in
	-f) g_force=true; ;;
	-v) g_verbose=true; ;;
	-q) g_quiet=true; ;;
	--unittest) unittest; exit; ;;
	*) shift; break; ;;
	esac
	shift
done

if (($# == 0)); then usage; fatal "Missing argument"; fi
if (($# != 1)); then fatal "Too many arguments"; fi

if ! "$g_force" && hash stow 2>/dev/null >&2; then
	quit "System stow detected - bailing out"
fi

mkdir -p "$1"
dest=$(readlink -f "$1")
if is_stow "$dest"/stow; then
	if ! "$g_force"; then
		quit "$g_version already installed in $dest"
	fi
fi

tmpd=/tmp/install-stow.$$
mkdir -p "$tmpd"
trap 'cd / ; run rm -rf "$tmpd"' EXIT

cd "$tmpd"
run curl -sSLo ./stow.tar.gz https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz
run tar xaf ./stow.tar.gz --strip-components=1 -C .
run ./configure --quiet --prefix="$tmpd/_ignore" --with-pmdir="$dest" --bindir="$dest"
run make install MAKEINFO=true
cd /
run rm -rf "$tmpd"

if ! is_stow "$dest"/stow; then
	fatal "Failed to install stow"
fi
quit "$g_version installed to $dest"

