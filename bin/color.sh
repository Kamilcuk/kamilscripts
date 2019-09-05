#!/bin/sh
set -eu

config="
#  this is the output of tput sgr0
reset \e(B\e[m

# specials
bold     \e[1m
bright 	 \e[1m
dim 	 \e[2m
underline 	 \e[4m
blink 	 \e[5m
reverse 	 \e[7m
hidden 	 \e[8m

reset_bold \e[21m
reset_bright \e[21m
reset_dim \e[22m
reset_underlined \e[24m
reset_blink \e[25m
reset_reverse \e[27m
reset_hidden \e[28m

# foreground colors
default	\e[39m
black	\e[30m
red	\e[31m
green	\e[32m
yellow	\e[33m
blue	\e[34m
magenta	\e[35m
cyan	\e[36m
light_gray	\e[37m
dark_gray	\e[90m
light_red	\e[91m
light_green	\e[92m
light_yellow	\e[93m
light_blue	\e[94m
light_magenta	\e[95m
light_cyan	\e[96m
white	\e[97m

# background colors
background_black \e[40m
background_red \e[41m
background_green \e[42m
background_yellow \e[43m
background_blue \e[44m
background_magenta \e[45m
background_cyan \e[46m
background_light_gray \e[47m
background_dark_gray \e[100m
background_light_red \e[101m
background_light_green \e[102m
background_light_yellow \e[103m
background_light_blue \e[104m
background_light_magenta \e[105m
background_light_cyan \e[106m
background_white \e[107m

# shortcuts to background colors, because typing background is long
b_black \e[40m
b_red \e[41m
b_green \e[42m
b_yellow \e[43m
b_blue \e[44m
b_magenta \e[45m
b_cyan \e[46m
b_light_gray \e[47m
b_dark_gray \e[100m
b_light_red \e[101m
b_light_green \e[102m
b_light_yellow \e[103m
b_light_blue \e[104m
b_light_magenta \e[105m
b_light_cyan \e[106m
b_white \e[107m

# special
test	test
"

config=$(printf "%s" "$config" | sed '/^$/d; /^#/d; s/\([^[:space:]]*\)[[:space:]]*\(.*\)/\1\t\2/')

#############################################################

usage() {
	cat <<EOF
Usage: color.sh [options] mode...

Options:
    -h --help   Print this help and exit
    -s --safe   If terminal does not support colors, print nothing.

Modes:
    $(printf "%s" "$config" | cut -f1 | tr '\n' ' ')
    test is a special mode that prints "test" string to the output. test it out.

Examples:
    color.sh red b_green; echo 123; color.sh reset
    color.sh green b_red test reset red b_green test

Written by Kamil Cukrowski
SPDX-License-Identifier: GPL-3.0+
EOF
}

bashautocomplete() {
	tmp=$(printf "%s" "$config" | cut -f1 | paste -sd' ')
	tmp="$tmp -h --help -s --safe"
	printf "complete -W %q color.sh\n" "$tmp"
}

# main ########################################################

args=$(getopt -n color.sh -o hs -l help,safe,bashautocomplete -- "$@")
eval set -- "$args"
safe=false
while [ "$#" -ne 0 ]; do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-s|--safe) safe=true; ;;
	--bashautocomplete) bashautocomplete; exit; ;;
	--) shift; break; ;;
	*) echo "Internal error" >&2; exit 2;
	esac
	shift
done

if ! hash tput >/dev/null 2>/dev/null; then
	echo "Could not find tput utility" >&2
	exit 2
fi

if ! ( colors=$(tput colors 2>/dev/null) && test -n "$colors" && test "$colors" -ge 8 ); then
        if [ "$safe" = "false" ]; then
		echo "ERROR: Terminal does not support colors" >&2
		exit 1
	else
		exit 0
	fi
fi

if [ "$#" -eq 0 ]; then
	usage
	exit 1
fi

h=""
for i; do
	if ! tmp=$(printf "%s" "$config" | grep -i "^$i"$'\t'); then
		echo "Unknown mode: $i" >&2
		exit 2
	fi
	tmp=$(printf "%s" "$tmp" | cut -f2)
	case "$tmp" in
	test) printf "%stest\n" "$h"; h=""; ;;
	*) printf "$tmp"; h+="$i "; ;;
	esac
done

