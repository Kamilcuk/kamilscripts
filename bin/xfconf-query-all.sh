#!/bin/bash
set -euo pipefail -o errtrace
export SHELLOPTS
trap 'kill 0' EXIT

if (($#)) && [[ "$1" = "-h" ]]; then
	echo "Options: -m"
	exit
fi

if (($# == 0)); then
	stdbuf -oL "$0" -m |
	stdbuf -oL sed -n '/\([^:]*\): \([^:]*\): \([^ ]*\)/{s//\1 \3 \2/;p}' |
	{
		tee >(
			grep --line-buffered -v ' set$' >&3
		) |
		grep --line-buffered ' set$' |
		while IFS=' ' read -r m p _; do
			echo "$m $p set $(xfconf-query -c "$m" -p "$p")"
		done
	} 3>&1 |
	stdbuf -oL sed 's/\([^ ]*\) \([^ ]*\) \([^ ]*\)/xfconf-query -c \1 -p \2 --\3/; s/--set/-s/'
	exit
fi

cmd=${1:--m}

# shellcheck disable=2016
xfconf-query -l |
tail -n+2 |
tee >(echo "+ xfconf-query $cmd -c {$(tr -d ' ' | sort | paste -sd,)}" >&2) |
stdbuf -oL xargs -P0 -n1 stdbuf -oL sh -c 'stdbuf -oL xfconf-query "$1" -c "$2" 2>&1 | stdbuf -oL sed "s/^/$2: /"' -- "$cmd"

