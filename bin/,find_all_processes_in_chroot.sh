#!/bin/bash
set -euo pipefail
export PATH="$(dirname "$0")":$PATH
. L_lib.sh L_argparse \
	-- dir type=dir \
	---- "$@"
L_assert "Must be run as root" test "$UID" -eq 0
prefix=$(readlink -f "$dir")
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
# shellcheck disable=2206
pids=($pids)
if ((${#pids[@]} == 0)); then
	echo "No pids running inside $1"
else
	echo "Found ${#pids[@]} running inside $1"
	echo "${pids[*]}"
fi

