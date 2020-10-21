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
fi
if [ -d "$HOME" ] && [ -e "$HOME"/.config/kamilscripts/kamilscripts ]; then
	appendpath "$HOME"/.config/kamilscripts/kamilscripts/bin
	KCDIR="$HOME"/.config/kamilscripts/kamilscripts
elif [ -d /usr/lib/kamilscripts/bin ]; then
	appendpath /usr/lib/kamilscripts/bin
	KCDIR=/usr/lib/kamilscripts
fi
unset appendpath
export PATH

# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
if command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
fi
export TMPDIR=/tmp
export COUNTRY=PL
export HISTSIZE=
export HISTFILESIZE=
mesg y

# https://wiki.archlinux.org/index.php/Makepkg
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

unset KCDIR

