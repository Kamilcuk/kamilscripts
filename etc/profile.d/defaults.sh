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
appendpath "$KCDIR"/secrets/bin
appendpath "$KCDIR"/bin
appendpath "$HOME"/.cargo/bin
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
# export TMPDIR=/tmp
export HISTSIZE=
export HISTFILESIZE=
if hash mesg 2>/dev/null; then
	mesg y
fi

# https://wiki.archlinux.org/index.php/Makepkg
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

# https://wiki.archlinux.org/index.php/Node.js
appendpath "$HOME/.node_modules/bin"
export npm_config_prefix="$HOME/.node_modules"

unset -f appendpath

# locale ##############################################################################

locale_supported() {
	[ -z "$( { LC_ALL=$1 ;} 2>&1 )" ]
}
_C_UTF="C"
_en_US="$_C_UTF"
if locale_supported en_US.UTF-8; then
	_en_US="en_US.UTF-8"
fi
_pl_PL="$_en_US"
if locale_supported pl_PL.UTF-8; then
	_pl_PL="pl_PL.UTF-8"
fi
unset -f locale_supported

export \
	LANG="$_en_US" \
	LANGUAGE="$_en_US" \
	LC_CTYPE="$_pl_PL" \
	LC_NUMERIC="$_en_US" \
	LC_TIME="$_pl_PL" \
	LC_COLLATE="$_C_UTF" \
	LC_MONETARY="$_pl_PL" \
	LC_MESSAGES="$_en_US" \
	LC_PAPER="$_pl_PL" \
	LC_NAME="$_pl_PL" \
	LC_ADDRESS="$_pl_PL" \
	LC_TELEPHONE="$_pl_PL" \
	LC_MEASUREMENT="$_pl_PL" \
	LC_IDENTIFICATION="$_pl_PL"

unset _C_UTF pl_PL en_US

