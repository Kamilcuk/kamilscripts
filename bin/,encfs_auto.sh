#!/bin/bash
set -euo pipefail

name=$(basename "$0")

usage() {
cat <<EOF
Usage: $name [options] dir [dir]

Manages encfs in a more normal way.

Options:
  -m                  Explicitly only mount.
  -u                  Explicitly only unmount.
  --no-default-flags  As in encfs
  -h                  Print this help and exit.

Usage cases:
    $name dir1 dir2
       If dir2 is not mounted, encfs mounts dir1 to dir2.
       If dir2 is mounted, then unmounts dir2.
    $name .dir
       Equal to $name .dir dir

Written by Kamil Cukrowski
EOF
}

fatal() {
	echo "$name: ERROR:" "$*" >&2
	exit 2
}



log() {
	echo "$@" >&2
	if ((g_graphic == 2)); then
		notify-send ",encfs $dir1 $dir2" "$@"
	fi
}

######################################################

args=$(getopt -n "$name" -o munhxg -l help,no-default-flags,graphic -- "$@")
eval "set -- $args"
mode=default
dry_run=false
g_encargs=()
g_graphic=0
while (($#)); do
	case "$1" in
	-m)  mode=mount; ;;
	-u)  mode=unmount; ;;
	-n)  dry_run=true; ;;
	-h|--help)  usage; exit; ;;
	--no-default-flags) g_encargs+=("$1"); ;;
	-g|--graphic) if [[ -v DISPLAY ]]; then g_graphic=1; fi; ;;
	-x) if [[ -v DISPLAY ]]; then g_graphic=2; fi; ;;
	--) shift; break; ;;
	*) fatal "unknown argument: $1"; ;;
	esac
	shift;
done

if (($# == 0)); then
	usage
	exit 1
fi
if (($# > 2)); then
	fatal "Too many arguments"
fi

dir1=$1
if (($# == 2)); then
	dir2=$2
else
	dir2=$(basename "$1")
	if [[ "${dir2:0:1}" != '.' ]]; then
		fatal "first character if first dir is not dot - don't know what to do with it: ${dir2} : ${dir2:0:1}"
	fi
	dir2="$(dirname "$1")/${dir2:1}"
fi
dir1="$(readlink -m "$dir1")"
dir2="$(readlink -m "$dir2")"

is_mounted=false
if mountpoint -q -- "$dir2"; then
	is_mounted=true
fi

dry_run() {
	echo "+" "$@"
	if ! "$dry_run"; then
		"$@"
	fi
}

notifyerror() {
	if ((g_graphic == 2)); then
		notify-send -i error ",encfs $dir1 $dir2" "$@"
	fi
}

domount() {
	if ((g_graphic)) && [[ -n "${DISPLAY:-}" ]] &&
		password=$(
			zenity --title ",encfs mounting $dir1 to $dir2" --entry --text "Give encfs password to $dir1:" --hide-text
		)
	then
		g_encargs+=( "--extpass=printf %s $(printf %q "$password")" )
	fi
	if ((g_graphic == 2)) && [[ -z "${password:-}" ]]; then
		notifyerror "Invalid password"
		exit 1
	fi
	log "Mounting $dir1 to $dir2"
	if ! dry_run encfs "${g_encargs[@]}" "$dir1" "$dir2"; then
		notifyerror "Invalid password"
		exit 1
	fi
}
dounmount() {
	log "Unmounting $dir2"
	if ! dry_run encfs "${g_encargs[@]}" -u "$dir2"; then
		notifyerror "Umounting $dir2 failed"
	fi
}

case "$mode" in
mount)
	if "$is_mounted"; then
		log "Already mounted: $dir2"
	else
		domount
	fi
	;;
unmount)
	if "$is_mounted"; then
		dounmount
	else
		log "Already unmounted: $dir2"
	fi
	;;
default)
	if "$is_mounted"; then
		dounmount
	else
		domount
	fi
	;;
*) fatal "Internal error"; ;;
esac

