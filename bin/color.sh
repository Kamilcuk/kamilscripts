#!/bin/sh
set -eu

config="
#  this is the output of tput sgr0
reset \e(B\e[m

# specials
bold     \e[1m
bright 	 \e[1m
dim 	 \e[2m
faint	\e[2m
standout	\e[3m
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
"

config=$(
	printf "%s\n" "$config" |
	sed '/^$/d; /^#/d; s/\([^[:space:]]*\)[[:space:]]*\(.*\)/\1\t\2/' |
	sort -s -k1
)

#############################################################

usage() {
	cat <<EOF
Usage: color.sh [options] mode...

Translated user readable format string in ascii escape seqeunces.

Options:
    -s --safe    If terminal does not support colors, print nothing.
                 The default is: print an error message and exit with nonzero exit status.
    -i --invert  Translate escape sequence into string. TODO, does nothing.
    -h --help    Print this help and exit.

Modes:
$(printf "%s" "$config" | cut -f1 | sed 's/^/    /' | if hash fmt 2>/dev/null; then fmt; else cut; fi)

    reset       - Resets the current settings.
    b_*         - Are shortcuts to background_*.
    test        - Print the string 'test' in requested mode.
    #RRGGBB     - Uses 8-bit or 24-bit colors for foreground.
    f#RRGGBB    - Uses 8-bit or 24-bit colors for foreground.
    b#RRGGBB    - Uses 8-bit or 24-bit colors for background.
    8#RGB       - 8-bit RGB code for foreground. Values must be within 0-5 range
    b8#RGB      - 8-bit RGB code for background.
    26#RRGGBB   - 24-bit RGB code for foreground.
    b26#RRGGBB  - 24-bit RGB code for background.

Examples:
    color.sh red b_green; echo 123; color.sh reset
    color.sh green b_red test reset red b_green test

Written by Kamil Cukrowski
SPDX-License-Identifier: GPL-3.0+
EOF
}

bashautocomplete() {
	local tmp
	tmp=$(printf "%s" "$config" | cut -f1 | paste -sd' ')
	tmp="$tmp -h --help -s --safe test reset # b# 8# b8# 26# b26#"
	printf "complete -W %q color.sh\n" "$tmp"
}

error() {
	local fmt
	fmt=$1
	shift
	printf "color.sh: ERROR: $fmt\n" "$@" >&2
	exit 2
}

erroron() {
	if eval "$1"; then
		local exp
		exp=$1
		shift
		error "Expr '%s' failed: %s" "$exp" "$*"
	fi
}

unittest() {
	if [ -z "$BASH_VERSION" ]; then
		echo "testing requires bash"
	fi
	$0 $(
		printf "%s" "$config" |
		cut -f1 |
		sed '/#.*/d; /^[[:space:]]$/d;' |
		sed 's/$/ test/'
	) 
	: reset test $(
		printf "%s test " {,b}8#{0,1,2,3,4,5}{0,1,2,3,4,5}{0,1,2,3,4,5}
	) reset test $(
		printf "%s test " {,b}24#{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}
	) reset test $(
		printf "%s test " {,b}#{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}{00,11,22,33,44,55,66,77,88,99,aa,bb,cc,dd,ee,ff}
	)
}

# main ########################################################

args=$(getopt -n color.sh -o hsdi -l help,safe,debug,invert,bashautocomplete,test -- "$@")
eval set -- "$args"
safe=false
invert=false
debug=false
while [ "$#" -ne 0 ]; do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-s|--safe) safe=true; ;;
	--bashautocomplete) bashautocomplete; exit; ;;
	-i|--invert) invert=true; ;;
	-d|--debug) debug=true; ;;
	--test) unittest; exit 0; ;;
	--) shift; break; ;;
	*) echo "Internal error" >&2; exit 2;
	esac
	shift
done

if ! hash tput >/dev/null 2>/dev/null; then
	echo "Could not find tput utility" >&2
	exit 2
fi

if ! colors=$(tput colors 2>/dev/null) || 
		[ -z "$colors" ] || 
		[ "$colors" -lt 8 ]; then
    if [ "$safe" = "false" ]; then
		echo "ERROR: Terminal does not support colors=$colors" >&2
		exit 1
	else
		exit 0
	fi
fi

if [ "$#" -eq 0 ]; then
	usage
	exit 1
fi

# main work

calc_8_bit() {
	local r g b tmp
	if ! ((
			r = 6#${1:0:1} ,
			g = 6#${1:1:1} ,
			b = 6#${1:2:1} ,
			tmp = 16 + 36 * r + 6 * g + b ,
			1
			)); then
		error "calc_8_bit: while calculating color expression from $1"
	fi
	if ((
			0 > r || r > 5 ||
			0 > g || g > 5 ||
			0 > g || b > 5 ||
			16 > tmp || tmp > 231
			)); then
		erroron '((0 > r))' "Color red $r must be greater or equal 0."
		erroron '((r > 5))' "Color red $r must be lower or equal 5."
		erroron '((0 > g))' "Color green $g must be greater or equal 0."
		erroron '((g > 5))' "Color green $g must be greater or equal 5."
		erroron '((0 > g))' "Color blue $b must be greater or equal 0."
		erroron '((b > 5))' "Color blue $b must be greater or equal 5."
		erroron '((tmp < 16))' "Calculated color=$tmp smaller then 16"
		erroron '((tmp > 231))' "Calculated color=$tmp greater then 231"
		erroron 'true' "Other error"
	fi
	printf "%s" "$tmp"
}

calc_24_bit() {
	local r g b tmp
	if ! ((
			r = 16#${1:0:2} ,
			g = 16#${1:2:2} ,
			b = 16#${1:4:2} ,
			1
			)); then
		error "calc_24_bit: while calculating color expression from $1"
	fi
	if ((
			0 > r || r > 256 ||
			0 > g || g > 256 ||
			0 > b || b > 256
			)); then
		erroron '((r < 0))' "Color red $r must be greater or equal 0."
		erroron '((r > 256))' "Color red $r must be lower or equal 256."
		erroron '((0 > g))' "Color green $g must be greater or equal 0."
		erroron '((g > 256))' "Color green $g must be greater or equal 256."
		erroron '((0 > g))' "Color blue $b must be greater or equal 0."
		erroron '((b > 256))' "Color blue $b must be greater or equal 256."
	fi
	printf "%s;%s;%s" "$r" "$g" "$b"
}

calc_32_bit_to_8_bit() {
	local r g b tmp
	if ! (( 
		r = 16#${1:1:2} * 5 / 256 ,
		g = 16#${1:3:2} * 5 / 256 ,
		b = 16#${1:5:2} * 5 / 256 ,
		1
	)); then
		error "calc_32_bit_to_8_bit: while calculating expression $1"
	fi
	tmp=$(printf "%02x%02x%02x" "$r" "$g" "$b")
	calc_24_bit "$tmp"
}

h=""
for i; do
	h+="$i "
	case "$i" in
	'8#'*)
		erroron '[ "${#i}" -ne 5 ]' "Input $i argument invalid."
		tmp=$(calc_8_bit "${i:2}") || error "while parsing $i"
		printf "\e[38;5;%sm" "$tmp"
		;;
	'b8#'*)
		erroron '[ "${#i}" -ne 6 ]' "Input $i argument invalid."
		tmp=$(calc_8_bit "${i:3}") || error "while parsing $i"
		printf "\e[48;5;%sm" "$tmp"
		;;
	'24#'*)
		erroron '[ "${#i}" -ne 9 ]' "Input $i argument invalid."
		tmp=$(calc_24_bit "${i:3}") || error "while parsing $i"
		printf "\e[38;2;%sm" "$tmp"
		;;
	'b24#'*)
		erroron '[ "${#i}" -ne 10 ]' "Input $i argument invalid."
		tmp=$(calc_24_bit "${i:5}") || error "while parsing $i"
		printf "\e[48;2;%sm" "$tmp"
		;;
	'#'*)
		erroron '[ "${#i}" -ne 7 ]' "Input $i argument invalid."
		if [ "$colors" -ge 256 ]; then
			tmp=$(calc_24_bit "${i:1}") || error "while parsing $i"
			printf "\e[38;2;%sm" "$tmp"
		elif [ "$colors" -ge 8 ]; then
			tmp=$(calc_32_bit_to_8_bit "${i:1}") || error "while parsing $i"
			printf "\e[38;5;%sm" "$tmp"	
		else
			error "colors=$colors unhandled"
		fi
		;;
	'f#'*)
		erroron '[ "${#i}" -ne 8 ]' "Input $i argument invalid."
		if [ "$colors" -ge 256 ]; then
			tmp=$(calc_24_bit "${i:2}") || error "while parsing $i"
			printf "\e[38;2;%sm" "$tmp"
		elif [ "$colors" -ge 8 ]; then
			tmp=$(calc_32_bit_to_8_bit "${i:2}") || error "while parsing $i"
			printf "\e[38;5;%sm" "$tmp"	
		else
			error "colors=$colors unhandled"
		fi
		;;
	'b#'*)
		erroron '[ "${#i}" -ne 8 ]' "Input $i argument invalid."
		if [ "$colors" -ge 256 ]; then
			tmp=$(calc_24_bit "${i:2}") || error "while parsing $i"
			printf "\e[48;2;%sm" "$tmp"
		elif [ "$colors" -ge 8 ]; then
			tmp=$(calc_32_bit_to_8_bit "${i:2}") || error "while parsing $i"
			printf "\e[48;5;%sm" "$tmp"	
		else
			error "colors=$colors unhandled"
		fi
		;;
	test)
		printf "%s\e(B\e[m\n" "$h"
		i=
		h=
		;;
	*)
		if ! tmp=$(printf "%s\n" "$config" | grep -i -m1 '^'"$i"$'\t'); then
			error "Unknown mode: $i"
		fi
		printf "$tmp" | cut -f2
		;;
	esac
done

