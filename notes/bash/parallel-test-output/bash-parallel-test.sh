#!/bin/bash
set -euo pipefail

trap_EXIT() {
	set +euo pipefail
	local -a -g tmps
	if (( $? )); then
		# print empty lines to move display
		yes "" | head -n "$#"
	fi
	# killall child processes
	read tmp < <(pgrep -P "$$" || true)
	tmp=$(grep "$$" <<<"$tmp")
	if [ -n "$tmp" ]; then kill -- $tmp; fi
	# wait for some timeout for them to end
	wait
	# remove tempfiles
	if (( $# )); then rm -f "$@"; fi;
}

tmps=()
trap 'trap_EXIT "${tmps[@]}"' EXIT

# run each function in another subshell
for func; do
	tmp=$(mktemp)
	tmps+=($tmp)
	( $func > $tmp ) &
done

echo

# run outputting subshell
( 
	num=0

	all_closed() { for f; do if lsof $f >/dev/null; then return 1; fi; done; return 0; }
	do_out() {
		local tmp
		local -g num
		tmp=$(paste -d$'\n' -s "${tmps[@]}")
		echo -ne "\r\033[${num}A"
		num=$(wc -l <<<"$tmp")
		cat <<<"$tmp"
	}


	while do_out; do
		if all_closed "${tmps[@]}"; then
			break;
		fi
		inotifywait -qq -e modify -e close "${tmps[@]}"
	done;
	do_out

) &

wait
