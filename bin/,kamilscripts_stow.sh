#!/bin/bash
set -euo pipefail
shopt -s extglob

name=$(basename "$0")
dir=$(readlink -f "$(dirname "$(readlink -f "$0")")")

usage() {
	cat <<EOF
Usage: $name [options] <mode>

Options:
  -h --help    Print this text and exit
  -f --force   Overwrite files
  -k --ok      Actually do changes

Modes:
  install
  uninstall

EOF
}

fatal() {
	echo "$name: ERROR:" "$@" >&2
	exit 2
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
	export PATH="$PATH:$b"
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

	cmd=(stow -d "$repo" -t ~ --no-folding ${STOWARGS[@]+"${STOWARGS[@]}"} "$@")
	echo "+ ${cmd[*]}"
	( cd "$repo" ; command "${cmd[@]}" )
}

stow_kamilscripts() {
	local packages repo
	repo="$(readlink -f "$dir/../stow")"
	packages=(common)
	if [[ -e "$repo/$HOSTNAME" ]]; then
		packages+=("$HOSTNAME")
	fi
	case "$HOSTNAME" in
	gucio|@(dudek|dzik|jenot|kumak|leszcz|wilga|bocian).cis.gov.pl)
		packages+=(fix_term_missing_italic); ;;
	esac

	do_stow "$repo" "$@" "${packages[@]}"
}

stow_work() {
	stow_manage_installation

	if "$dryrun"; then
		echo "Dry run. Add --ok to actually run"
	fi

	stow_kamilscripts "$@"
}

# main ##############################################################################

args=$(getopt -n "$name" -o hfk -l help,force,ok -- "$@")
eval set -- "$args"
dryrun=true
STOWARGS=()
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-f|--force) STOWARGS+=(--override='.*'); ;;
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

