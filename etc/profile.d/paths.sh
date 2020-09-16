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
if [ "$HOME" ]; then
	appendpath "$HOME"/bin
	appendpath "$HOME"/.config/bin
fi
if [ -d /usr/lib/kamilscripts/bin ]; then
	appendpath /usr/lib/kamilscripts/bin
fi
unset appendpath
export PATH

