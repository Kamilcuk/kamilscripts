#!/bin/bash
set -euo pipefail
name=$(basename "$0")
usage() {
cat <<EOF
Usage: $name [options] dir [dir]

Manages encfs in a more normal way.

Options:
  -m   Explicitly only mount.
  -u   Explicitly only unmount.
  -h   Print this help and exit.

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
	echo "$*"
}

######################################################

args=$(getopt -n "$name" -o 'munb' -- "$@")
eval "set -- $args"
mode=default
dry_run=false
while (($#)); do
	case "$1" in
	-m)  mode=mount; ;;
	-u)  mode=unmount; ;;
	-n)  dry_run=true; ;;
	-h)  usage; exit; ;;
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

domount() {
	log "Mounting $dir1 to $dir2"
	dry_run encfs "$(readlink -m "$dir1")" "$(readlink -m "$dir2")"
}
dounmount() {
	log "Unmounting $dir2"
	dry_run encfs -u "$(readlink -m "$dir2")"
}

case "$mode" in
mount)
	if "$is_mounted"; then
		log "already mounted: $dir2"
	else
		domount
	fi
	;;
unmount)
	if "$is_mounted"; then
		dounmount
	else
		log "Already mounted"
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

