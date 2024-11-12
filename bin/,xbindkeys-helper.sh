#!/bin/bash

# This is a small helper run from my xbindkeys shortcuts

name="${BASH_SOURCE##*/}"

html-quote() {
	sed '
		s/\&/\&amp;/g
		s/</\&lt;/g
		s/>/\&gt;/g
	'
}

usage() {
	cat <<EOF
Usage:
	$name [OPTIONS] <cmd>
	$name [OPTIONS] <text> <cmd>

Options:
	-i --icon   Add this icon to notifysend
	-h --help   Print this help and exit.

Written by Kamil Cukrowski
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3..
EOF
}

log() {
	echo "$name:" "$@"
}

fatal() {
	echo "$name: ERROR:" "$@" >&2
	exit 1
}

int_to_bool() {
	case "$1" in
	1) echo true; ;;
	*) echo false; ;;
	esac
}

###############################################################################

args=$(getopt -n "$name" -o +i:h -l icon:,help -- "$@")
eval set -- "$args"
g_icon=forward;
while (($#)); do
	case "$1" in
	-i|--icon) g_icon="$2"; shift; ;;
	-h|--help) usage; exit; ;;
	--) shift; break; ;;
	*) fatal "error when parsing arugment: $1"; ;;
	esac
	shift
done

if (($# > 2)); then fatal "Too many arguments"; fi

if (($# >= 2)); then
	text=$1
	shift
else
	text=""
fi

nohup bash -xc "$*" >/dev/null </dev/null 2>&1 &
if hash notify-send 2>/dev/null >/dev/null; then
	notify-send -u low -i "$g_icon" -t 2000 "xbindkeys" "$(cat <<EOF
${text:+<big><b>    $(html-quote <<<"$text")</b></big>
}<small>Running: <tt>$(html-quote <<<"$*")</tt></small>
EOF
)"
fi
