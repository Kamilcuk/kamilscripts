#!/bin/bash
set -euo pipefail

name=$(basename "$0")

usage() {
	cat <<EOF
Usage:
	$name -u <directory>
	$name <image> <directory>
	$name -c <image> COMMAND [ARGS...]
	$name [OPTIONS]

Options:
  -c       Interpret as command mode
  -u       Umount the directory
  -p NUM   Mount this partition number, by default 0.
  -h       Print help and exit.

Mount qemu-img image <image> to the <directory>.
Automatically manages free /dev/nbd* devices
When running with -c option, automatically unmounts
the image after command exist.

Written by Kamil Cukrowski
Licensed jointly under Beerware and MIT License
EOF
	exit
}

trap_ERR() {
	echo "Unhandled error" >&2
	exit 1
}
trap trap_ERR ERR

fatal() {
	echo "$name: ERROR:" "$*" >&2
	trap '' ERR
	exit 1
}

run() {
	echo "+" "$@"
	"$@"
}

get_next_free_qemu_nbd() {
	(
	cd /sys/class/block/
	for x in nbd[2-9] nbd[0-9][0-9]; do
		if ! s=$(cat "$x"/size); then continue; fi
		if [[ "$s" == "0" ]]; then
			echo "/dev/$x"
			exit 0
		fi
	done
	exit 1
	)
}

#########################################################

if [[ $UID -ne 0 ]]; then
	echo Restarting as root...
	run exec sudo "$0" "$@"
fi

args=$(getopt -n "mount_qemu.sh" -o cump:h -l help -- "$@")
eval set -- "$args"
g_mode=mount
g_partition=1
while (($#)); do
	case "$1" in
	-h) usage; exit; ;;
	-c) g_mode=command; ;;
	-u) g_mode=umount; ;;
	-m) g_mode=mount; ;;
	-p) g_partition=$2; shift; ;;
	--) shift; break; ;;
	*) fatal "unknown option: $1"; ;;
	esac
	shift
done
if (($# == 0)); then 
	usage
	fatal "Not enough arguments"
fi


if [[ ! -f "$1" ]]; then 
	fatal "No such file: $1"
fi
if [[ ! -r "$1" ]]; then 
	fatal "Could not read from file: $1"
fi

#################

if ! lsmod | grep -q '^nbd'; then
	( set -x;
	if rmmod nbd; then
		modprobe nbd max_part=16 ||
		modprobe nbd max_parts=16
	fi
	) ||:
fi

m_get_free_nbd() {
	if ! nbddev=$(get_next_free_qemu_nbd); then
		fatal "No free /dev/nbd* found!"
	fi
}

case "$g_mode" in
"mount")
	if (($# != 2)); then fatal "Wrong number of arguments fod mount"; fi
	image=$1
	shift
	m_get_free_nbd
	mkdir -p "$2"
	run qemu-nbd -c "$nbddev" "$image"
	trap 'qemu-nbd -d "$nbddev"'
	partprobe "$nbddev"
	run mount "$nbddev"p"$g_partition" "$mountd"
	trap '' EXIT
	;;
"command")
	if (($# < 2)); then fatal "Not enough arguments for command"; fi
	image=$1
	shift
	m_get_free_nbd
	mountd=$(mktemp -d)
	trap 'rmdir "$mountd"' EXIT
	run qemu-nbd -c "$nbddev" "$image"
	trap 'rmdir "$mountd" ; qemu-nbd -d "$nbddev"' EXIT
	partprobe "$nbddev"
	run mount "$nbddev"p"$g_partition" "$mountd"
	trap 'umount "$mountd" ; rmdir "$mountd" ; qemu-nbd -d "$nbddev"' EXIT
	(
		cd "$mountd"
		"$@"
	)
	;;
"umount")
	if (($# != 1)); then fatal "Wrong number of arguments"; fi
	nbddev=$(findmnt -n -o SOURCE --target "$1")
	umount "$1"
	qemu-nbd -d "$nbddev"
	;;
*)
	fatal "Internal error: Wrong mode: $g_mode"
	;;
esac

