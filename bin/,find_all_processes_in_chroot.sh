#!/bin/bash
set -euo pipefail

. "$(dirname "$0")"/,lib_lib -q

usage() {
	echo "Usage: $0 <dir with chroot>"
	exit
}
fatal() { L_fatal "$@"; }

if (($# != 1)); then usage; fi
if ((UID != 0)); then L_fatal "Must be run as root"; fi
if [[ ! -d "$1" ]]; then fatal "Directory does not exists: $1"; fi

prefix=$(readlink -f $1)
pids=$(
	for root in /proc/[0-9]*/root; do
		if link=$(readlink "$root") &&
				[[ -n "$link" ]] &&
				[[ "${link:0:${#prefix}}" == "$prefix" ]]; then
			pid=$root
			pid=${pid%/*}
			pid=${pid##*/}
			echo "$pid"
		fi &
	done
	wait
)
if [[ -z "$pids" ]]; then
	echo "No pids running inside $1"
else
	echo "Found $(<<<$pids wc -w) running inside $1"
	echo $pids
fi

