#!/bin/sh

appendpath () {
	case ":$PATH:" in
		*:"$1":*) ;;
		*) PATH="${PATH:+$PATH:}$1"; ;;
	esac
}

appendpath "$HOME"/bin
appendpath "$HOME"/.local/bin
appendpath "${XDG_CONFIG_HOME:-"$HOME"/.config}"/bin
appendpath "$KCDIR"/bin
appendpath /usr/local/sbin
appendpath /usr/local/bin
appendpath /usr/sbin
appendpath /usr/bin
appendpath /sbin
appendpath /bin
export PATH

# https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
	export VISUAL=nvim
elif command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
elif command -v vi >/dev/null 2>&1; then
	export EDITOR=vi
	export VISUAL=vi
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

# man watch
export WATCH_INTERVAL=1

# locale ##############################################################################

locale_supported() {
	[ -z "$( { LC_ALL=$1 ;} 2>&1 )" ]
}
en_US=""
if locale_supported en_US.UTF-8; then
	en_US="en_US.UTF-8"
fi
pl_PL=""
if locale_supported pl_PL.UTF-8; then
	pl_PL="pl_PL.UTF-8"
fi
unset -f locale_supported

export LANG=${en_US:-C}
export LC_CTYPE=${pl_PL:-${en_US:-C}}
export LC_NUMERIC=${en_US:-C}
export LC_TIME=${pl_PL:-${en_US:-C}}
export LC_COLLATE=C
export LC_MONETARY=${en_US:-C}
export LC_MESSAGES=${en_US:-C}
export LC_PAPER=${en_US:-C}
export LC_NAME=${en_US:-C}
export LC_ADDRESS=${en_US:-C}
export LC_TELEPHONE=${en_US:-C}
export LC_MEASUREMENT=${en_US:-C}
export LC_IDENTIFICATION=${en_US:-C}

unset pl_PL en_US

