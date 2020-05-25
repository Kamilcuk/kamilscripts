#!/bin/bash
set -euo pipefail

usage(){
cat <<EOF
Usgae: ttoc.sh [-h|--help] [id]
Tic/toc timer pair.
Prints the time passed since the last ttic invocation.
Temporary timer file is stored at /tmp/.ttic[.ID].txt

Examples:
       # Global timer (not recommended)
       ttic && (do work) && ttoc
       # Using FooBar as id
       ttic FooBar && (do work) && ttoc FooBar
       # Using a randomly generated id
       id=\$(ttic -u) && (do work) && ttoc \$id

Original author:
       https://gist.github.com/swarminglogic/87adb0bd0850d76ba09f
       Roald Fernandez (github@swarminglogic.com)

Written by Kamil Cukrowski
Licensed under GPL-3.0 License
SPXD-License-Identifier GPL-3.0
EOF
}


while (($#)); do
    case "$1" in
        -h|--help)
            usage
	    exit 1
            ;;
        *)
            id=$1
            shift
            break
            ;;
    esac
done

if (($#)); then
	echo "ERROR: Too many arguments: " "$@" >&2
	exit 1
fi

# ${var:+1} expands to 1 if var is set
tmpfile="/tmp/.ttic${id:+."$id"}.txt"

if [ ! -e "$tmpfile" ] ; then
    echo "ERROR: Did not find initalized time file. Run ttic with same id before ttoc!" >&2
    exit 1
fi

tic=$(<"$tmpfile")
toc=$(date +%s%N)
delta=$((toc - tic))
printf '%g\n' "$((delta / 1000000000)).$(printf "%09d" "$((delta % 1000000000))")"

