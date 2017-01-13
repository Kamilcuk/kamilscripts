#!/bin/bash -e

#gitdir=$(git rev-parse --show-toplevel)
gitdir="$(dirname $(dirname $(readlink -f "$0")))"
cd $gitdir
dstdir=${dstdir:-pkg-archlinux/src/}

if [ -z "$dstdir" ]; then
	echo "ERROR - empty destination directory"
	exit 1
fi

rsyncargs=()
[ -d public/resources ] && 
	rsyncargs+=( "$(readlink -f public/resources)/" )
[ -d crypted/resources ] && 
	rsyncargs+=( "$(readlink -f crypted/resources)/" )

if [ "$1" != '-s' ]; then
	( set -x
	rsync -avh --delete "${rsyncargs=[@]}" "$dstdir"
	)
else 
	rsync -ah  --delete "${rsyncargs=[@]}" "$dstdir"
fi

