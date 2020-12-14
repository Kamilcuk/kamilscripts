#!/bin/bash
set -euo pipefail

name=$(basename "$0")
dir=$(readlink -f "$(dirname "$(readlink -f "$0")")")

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

git_submodule_update() {
	if ! "$dryrun"; then
		(
		set -xeuo pipefail
		cd "$dir"
		local tmp
		tmp="$(git rev-parse --show-toplevel)"
		cd "$tmp"
		git submodule update --recursive --init
		)
	fi
}

stow_manage_installation() {
	local d b
	d=~/.config/kamilscripts/stow
	b=~/.config/bin
	if hash stow 2>/dev/null >&2; then
		if [[ -e "$b"/stow && -d "$d" && ( -x /usr/bin/stow || -x /bin/stow ) ]]; then
			echo "### System stow installation exists, removing our installation"
			( set -x
			rm -rf "$d" "$b"/stow "$b"/chkconfig
			)
		fi
		if ! hash stow 2>/dev/null >&2; then
			fatal "Something went horribly wrong when removing stow"
		fi
		return
	fi
	if [[ ! -x "$d/stow" ]] || ! "$d"/stow --version 2>/dev/null >&2; then
		echo "### Installing stow..." >&2
		( set -xeuo pipefail
		rm -rf "$d" &&
		mkdir -p "$d"/src &&
		cd "$d"/src &&
		wget https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz &&
		tar xaf stow-latest.tar.gz --strip-components=1 -C . &&
		./configure --quiet --prefix="$d" --with-pmdir="$d" --bindir="$d" &&
		make install MAKEINFO=true &&
		cd "$d" &&
		rm -rf "$d"/src/ "$d"/share/
		)
		if ! "$d"/stow --version 2>/dev/null >&2; then
			echo "### stow installed unsuccessfully"
			exit 1
		fi
		mkdir -p "$b"
		ln -fs "$d"/stow "$b"/stow
		ln -fs "$d"/chkstow "$b"/chkstow
		echo "### stow installed!" >&2
	fi
	export PATH="$PATH:$b"
}

do_stow() {
	local repo
	repo=$1
	shift

	if "$dryrun"; then
		set -- '-n' "$@"
	fi
	set -- '-v' "$@"

	if [[ ! -r "$repo"/.stowrc ]]; then
		fatal "$repo/.stowrc not such file"
	fi

	echo "+" "cd" "$repo" "&&" stow "$@"
	pushd "$repo" >/dev/null
	command stow "$@"
	popd >/dev/null
}

stow_kamilscripts() {
	local packages
	packages=(common "$HOSTNAME")
	case "$HOSTNAME" in
	gucio|bocian.cis.gov.pl) packages+=(fix_term_missing_italic); ;;
	esac

	do_stow "$(readlink -f "$dir/../stow")" "$@" "${packages[@]}"
}

stow_work() {
	stow_manage_installation

	if "$dryrun"; then
		echo "Dry run. Add --ok to actually run"
	fi

	stow_kamilscripts "$@"
}

# main ##############################################################################

args=$(getopt -n "$name" -o hk -l help,ok -- "$@")
eval set -- "$args"
dryrun=true
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-k|--ok) dryrun=false; ;;
	--) shift; break; ;;
	esac
	shift
done

if (($#==0)); then usage; exit 1; fi
case "$1" in
i|install)    stow_work -R; ;;
u|uninstall)  stow_work -D; ;;
*) echo "Unknown mode: $1" >&2; ;;
esac

