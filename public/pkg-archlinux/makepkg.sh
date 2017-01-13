#!/bin/bash -e

DIR=$(readlink -f $(dirname $(readlink -f $0)))
cd $DIR
if ! findmnt ../. >/dev/null 2>/dev/null; then
	echo "Probably you want to mountunion.sh"
	exit 1
fi
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"
makepkg "$@"

