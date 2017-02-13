#!/bin/bash -e

#gitdir=$(git rev-parse --show-toplevel)
gitdir="$(dirname $(dirname $(readlink -f "$0")))"
cd $gitdir

./pkg-archlinux/rsync_all_pkg_resources.sh -s
if ! ./checkifthisrepoisdecripted.sh; then
	echo "Error"
	exit 1
fi

cd pkg-archlinux
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"
# TODO export BUILDDIR=/tmp/kamil-scripts-makepkg
( set -x
  makepkg -c "$@"
)

