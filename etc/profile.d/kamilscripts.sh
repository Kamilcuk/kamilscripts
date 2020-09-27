#!/bin/sh

appendpath () {
    case ":$PATH:" in
        "$1":*|*:"$1":*|*:"$1") ;;
        *) PATH="${PATH:+$PATH:}$1"; ;;
    esac
}

appendpath /usr/local/sbin
appendpath /usr/local/bin
appendpath /usr/sbin
appendpath /usr/bin
appendpath /sbin
appendpath /bin
if [ -d "$HOME" ]; then
	appendpath "$HOME"/bin
	appendpath "$HOME"/.config/bin
	if [ -e "$HOME"/.config/kamilscripts/kamilscripts ]; then
		appendpath "$HOME"/.config/kamilscripts/kamilscripts/bin
		KCDIR="$HOME"/.config/kamilscripts/kamilscripts
	fi
fi
if [ -d /usr/lib/kamilscripts/bin ]; then
	appendpath /usr/lib/kamilscripts/bin
	KCDIR=/usr/lib/kamilscripts
fi
unset appendpath
export PATH

# set some environmental variables
export EDITOR="$(command -v vim)"
export VISUAL="$EDITOR"
export TMPDIR=/tmp
export COUNTRY=PL
mesg y

# https://wiki.archlinux.org/index.php/Makepkg
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

unset KCDIR

