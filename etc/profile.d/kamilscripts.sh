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
for i in \
		/usr/lib/kamilscripts \
		"$HOME"/.kamilscripts \
		"$HOME"/.config/kamilscripts/kamilscripts \
		"$HOME"/.config/kamilscripts \
; do
	if [ -e "$i" ] && [ -e "$i"/.git ] && [ -e "$i"/bin ]; then
		i=$(readlink -f "$i")
		KCDIR="$i"
		appendpath "$KCDIR"/bin
		break
	fi
done
unset i
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

# https://wiki.archlinux.org/index.php/Node.js
appendpath "$HOME/.node_modules/bin"
export npm_config_prefix="$HOME/.node_modules"

unset -f appendpath
unset KCDIR

