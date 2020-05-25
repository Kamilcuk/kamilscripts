#!/bin/bash
set -euo pipefail

name=$(basename "$0")

# SEE regenerate_config
# BEGIN blockinfile.sh MANAGED BLOCK
declare -- config="b_black	\\e[40m
b_blue	\\e[44m
b_cyan	\\e[46m
b_dark_gray	\\e[100m
b_green	\\e[42m
b_light_blue	\\e[104m
b_light_cyan	\\e[106m
b_light_gray	\\e[47m
b_light_green	\\e[102m
b_light_magenta	\\e[105m
b_light_red	\\e[101m
b_light_yellow	\\e[103m
b_magenta	\\e[45m
b_red	\\e[41m
b_white	\\e[107m
b_yellow	\\e[43m
background_black	\\e[40m
background_blue	\\e[44m
background_cyan	\\e[46m
background_dark_gray	\\e[100m
background_default	\\e[49m
background_green	\\e[42m
background_light_blue	\\e[104m
background_light_cyan	\\e[106m
background_light_gray	\\e[47m
background_light_green	\\e[102m
background_light_magenta	\\e[105m
background_light_red	\\e[101m
background_light_yellow	\\e[103m
background_magenta	\\e[45m
background_red	\\e[41m
background_white	\\e[107m
background_yellow	\\e[43m
black	\\e[30m
blink	\\e[5m
blue	\\e[34m
bold	\\e[1m
bright	\\e[1m
conceal	\\e[8m
crossedout	\\e[9m
cyan	\\e[36m
dark_gray	\\e[90m
default	\\e[39m
dim	\\e[2m
double_underline	\\e[21m
encircled	\\e[52m
faint	\\e[2m
font0	\\e10m
font1	\\e11m
font2	\\e12m
font3	\\e13m
font4	\\e14m
font5	\\e15m
font6	\\e16m
font7	\\e17m
font8	\\e18m
font9	\\e19m
foreground_default	\\e[39m
fraktur	\\e[20m
framed	\\e[51m
green	\\e[32m
hidden	\\e[8m
light_blue	\\e[94m
light_cyan	\\e[96m
light_gray	\\e[37m
light_green	\\e[92m
light_magenta	\\e[95m
light_red	\\e[91m
light_yellow	\\e[93m
magenta	\\e[35m
noblink	\\e[25m
nocrossedout	\\e[29m
nodim	\\e[22m
noencircled	\\e[54m
noframed	\\e[54m
nohidden	\\e[28m
nooverlined	\\e[55m
noreverse	\\e[27m
nostandout	\\e[23m
nounderline	\\e[24m
overlined	\\e[53m
red	\\e[31m
reset	\\e(B\\e[m
reveal	\\e[28m
reverse	\\e[7m
standout	\\e[3m
underline	\\e[4m
white	\\e[97m
yellow	\\e[33m"
# END blockinfile.sh MANAGED BLOCK

regenerate_config() {
	config="
#  this is the output of tput sgr0
reset          \e(B\e[m

# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters

# specials
bold           \e[1m
bright         \e[1m
dim            \e[2m
faint          \e[2m
standout       \e[3m
underline      \e[4m
blink          \e[5m
reverse        \e[7m
hidden         \e[8m
conceal        \e[8m
crossedout     \e[9m

# fonts
font0          \e10m
font1          \e11m
font2          \e12m
font3          \e13m
font4          \e14m
font5          \e15m
font6          \e16m
font7          \e17m
font8          \e18m
font9          \e19m

fraktur        \e[20m
# ECMA-48
double_underline  \e[21m
# nobold          \e[21m
# nobright        \e[21m
nodim             \e[22m
nostandout        \e[23m
nounderline       \e[24m
noblink           \e[25m
noreverse         \e[27m
nohidden          \e[28m
reveal            \e[28m
nocrossedout      \e[29m

# foreground colors
black          \e[30m
red            \e[31m
green          \e[32m
yellow         \e[33m
blue           \e[34m
magenta        \e[35m
cyan           \e[36m
light_gray     \e[37m

foreground_default  \e[39m
default             \e[39m

# background colors
background_black          \e[40m
background_red            \e[41m
background_green          \e[42m
background_yellow         \e[43m
background_blue           \e[44m
background_magenta        \e[45m
background_cyan           \e[46m
background_light_gray     \e[47m
background_default        \e[49m

# others
framed         \e[51m
encircled      \e[52m
overlined      \e[53m
noframed       \e[54m
noencircled    \e[54m
nooverlined    \e[55m

# set bright foreground color
dark_gray      \e[90m
light_red      \e[91m
light_green    \e[92m
light_yellow   \e[93m
light_blue     \e[94m
light_magenta  \e[95m
light_cyan     \e[96m
white          \e[97m

# set bright background color
background_dark_gray      \e[100m
background_light_red      \e[101m
background_light_green    \e[102m
background_light_yellow   \e[103m
background_light_blue     \e[104m
background_light_magenta  \e[105m
background_light_cyan     \e[106m
background_white          \e[107m

# shortcuts to background colors, because typing background is long
b_black           \e[40m
b_red             \e[41m
b_green           \e[42m
b_yellow          \e[43m
b_blue            \e[44m
b_magenta         \e[45m
b_cyan            \e[46m
b_light_gray      \e[47m

b_dark_gray       \e[100m
b_light_red       \e[101m
b_light_green     \e[102m
b_light_yellow    \e[103m
b_light_blue      \e[104m
b_light_magenta   \e[105m
b_light_cyan      \e[106m
b_white           \e[107m

"

	config=$(
	    <<<"$config" \
	    sed -n 's/^\([^ ]*\)[[:space:]]*\(\\e[^ ]*\)$/\1\t\2/p' |
	    sort
	)

	blockinfile.sh -b "$(declare -p config)" "$0"
}

#############################################################

usage() {
	cat <<EOF
Usage: $name [options] mode...

Translated user readable format string in ascii escape seqeunces.

Options:
    -s --safe        If terminal does not support colors, print nothing.
                     The default is: print an error message and exit with nonzero exit status.
    -i --invert      Translate escape sequence into string. TODO, WIP, does nothing.
    -h --help        Print this help and exit.
       --test[=NUM]  Print all possible configurations. Optionally specify test part number.
       --separator=STR        Output specified separator between each mode.
       --bashautocompletaion  Output a bash complation invocation that needs to be eval-ed.
    -d --debug       Basically sets set -x.

Modes:
$(printf "%s" "$config" | sed 's/[ #].*//' | sed '/^[[:space:]]*$/d' | sort | if hash fmt 2>/dev/null; then fmt; else cut; fi)

  b_*         - Are shortcuts to background_*.
  reset       - Resets the current settings.
  test        - Print the string 'test' in requested mode.
  f8#RGB      - 8-bit RGB code for foreground. Values must be within 0-5 range
  b8#RGB      - 8-bit RGB code for background.
  f26#RRGGBB  - 24-bit RGB code for foreground.
  b26#RRGGBB  - 24-bit RGB code for background.
  RRGGBB     - Same as f#RRGGBB.
  f#RRGGBB    - Uses 8-bit or 24-bit colors for foreground.
  b#RRGGBB    - Uses 8-bit or 24-bit colors for background.
  print "text"  - print the text
  echo "text"   - print the text with a newline
  charrainbow RRGGBB RRGGBB "text" 
                - print each word from text using colors from one color to another
  charrainbow3 RRGGBB RRGGBB RRGGBB "text"
                - print each word from text using colors changing from 3 colors
  colors        - runs tput colors

Examples:
    color.sh red b_green; echo 123; color.sh reset
    color.sh green b_red test reset red b_green test
    color.sh charrainbow ff0000 00ff00 this_is_funny_string
    color.sh charrainbow3 ff0000 00ff00 00000ff this_is_funny_string

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
	local part curpart
	part=${1:--1}
	if [ -z "$BASH_VERSION" ]; then
		echo "testing requires bash"
	fi

	curpart=0

	testit() {
		local -g part curpart
		if (( part != -1 && part != ++curpart )); then
			return 0
		fi
		$0 "$@"
	}

	shouldfail() {
		local -g part curpart
		if (( part != -1 && part != ++curpart )); then
			return 0
		fi
		if $0 "$@" 2>/dev/null; then
			echo "TEST" "$*" failed
			exit 1
		fi
	}

	testit $(
		<<<"$config" sed \
		'/#.*/d; /^[[:space:]]*$/d; s/^\([^[:space:]]*\).*$/\1 test/' |
		sort
	) reset test

	testit $(
		printf "%s test " {f,b}8#{0,1,2,3,4,5}{0,1,2,3,4,5}{0,1,2,3,4,5}
	) reset test

	testit $(
		printf "%s test " {f,b}24#{00,55,77,aa,ff}{00,55,77,aa,ff}{00,55,77,aa,ff}
	) reset test 

	testit $(
		printf "%s test " {f#,b#,}{00,55,77,aa,ff}{00,55,77,aa,ff}{00,55,77,aa,ff}
	) reset test

	testit charrainbow 000000 ff0000 funny_colored_string_that_is_long echo ''
	testit charrainbow 0000ff 00ff00 funny_colored_string_that_is_long echo ''
	testit charrainbow ff0000 0000ff funny_colored_string_that_is_long echo ''
	testit charrainbow ffff00 ff7700 funny_colored_string_that_is_long echo ''
	testit charrainbow 0000ff 00ff00 funny_colored_string_that_is_long_and_it_is_really_really_long_and_cool_looking echo '' \
	reset print "some string"$'\n'
	testit charrainbow3 0000ff 00ff00 ff0000 funny_colored_string_that_is_long_and_it_is_really_really_long_and_cool_looking echo ''

	shouldfail echo
	shouldfail print
	shouldfail charrainbow dfhaf fbhfbajfb bfhda
	shouldfail charrainbow dfhaf fbhfbajfb bfhda
	shouldfail fndjsanfjk fnasjjf
	shouldfail f24#fjfnfn
	shouldfail b24#fjfnfn
	shouldfail f8#666
	shouldfail f8#-1-1-1
	shouldfail f8#GGG
	shouldfail b8#GGG

	testit echo "test finished ! "

}

# main ########################################################

args=$(getopt -n color -o hsdi -l help,safe,debug,invert,bashautocomplete,test::,separator: -- "$@")
eval set -- "$args"
safe=false
invert=false
debug=false
separator=
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-s|--safe) safe=true; ;;
	--bashautocomplete) bashautocomplete; exit; ;;
	-i|--invert) invert=true; ;;
	-d|--debug) debug=true; ;;
	--test) unittest "$2"; exit 0; ;;
	--separator) separator="$2"; shift; ;;
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
		[[ -z "$colors" ]] || 
		(( colors < 8 )); then
    if ! "$safe"; then
		echo "ERROR: Terminal does not support colors=$colors" >&2
		exit 1
	else
		exit 0
	fi
fi

if (($# == 0)); then
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

fb8_hash() {
	local tmp num i
	i=$1
	erroron '[ "${#i}" -ne 6 ]' "Input $i argument invalid."
	tmp=$(calc_8_bit "${i:3}") || error "while parsing $i"
	case "${1:0:1}" in 
		f) num=3; ;; b) num=4; ;; 
		*) error 'Invalid first character of $1 argument'; ;;
	esac
	printf "\e[%s8;5;%sm" "$num" "$tmp"
}

fb24_hash() {
	local tmp num i
	i=$1
	erroron '[ "${#i}" -ne 10 ]' "Input $1 argument invalid."
	tmp=$(calc_24_bit "${1:4}") || error "while parsing $1"
	case "${1:0:1}" in 
		f) num=3; ;; b) num=4; ;; 
		*) error 'Invalid first character of $1 argument'; ;;
	esac
	printf "\e[%s8;2;%sm" "$num" "$tmp"
}

fb_hash() {
	local tmp num i
	i=$1
	erroron '[ "${#i}" -ne 8 ]' "Input '$1' argument invalid."
	case "${1:0:1}" in 
		f) num=3; ;; b) num=4; ;; 
		*) error 'Invalid first character of $1 argument'; ;;
	esac
	if [ "$colors" -ge 256 ]; then
		tmp=$(calc_24_bit "${1:2}") || error "while parsing $1"
		printf "\e[%d8;2;%sm" "$num" "$tmp"
	elif [ "$colors" -ge 8 ]; then
		tmp=$(calc_32_bit_to_8_bit "${1:2}") || error "while parsing $1"
		printf "\e[%d8;5;%sm" "$num" "$tmp"	
	else
		if ! "$safe"; then
			error "colors=$colors unhandled"
		fi
	fi
}

charrainbow() {
	local tmp br bg bb er eg eb l sr sg sb i
	tmp=$(printf "%s" "$3" | wc -c)
	(( 
		br = 16#${1:0:2} ,
		bg = 16#${1:2:2} ,
		bb = 16#${1:4:2} ,
		er = 16#${2:0:2} ,
		eg = 16#${2:2:2} ,
		eb = 16#${2:4:2} ,
		l = tmp ,
		sr = (er - br) / l ,
		sg = (eg - bg) / l ,
		sb = (eb - bb) / l ,
		1
	))
	for ((i = 0; i < l; i++)); do
		tmp=$(printf "f#%02x%02x%02x" $((br+sr*i)) $((bg+sg*i)) $((bb+sb*i)))
  		fb_hash "$tmp"
  		printf "%s" "${3:$i:1}"
	done
}

charrainbow3() {
	charrainbow "$1" "$2" "${4::${#4}/2}"
	charrainbow "$2" "$3" "${4:${#4}/2}"
}

h=""
while (($#)); do
	if ((${firstarg:-0})); then
		printf "%s" "$separator"
	else
		firstarg=1
	fi

	if tmp=$(
			<<<"$config" join --nocheck-order -11 -21 -o1.2 - <(printf "%s\n" "$1")) &&
			[ -n "$tmp" ]; then
		printf "$tmp"
		h+="$1 "
		shift
		continue
	fi

	i="$1"
	shift

	h+="$i "

	case "$i" in
	[fb]'8#'*)  fb8_hash "$i"; ;;
	[fb]'24#'*)  fb24_hash "$i"; ;;
	[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])  fb_hash f#"$i"; ;;
	[fb]'#'*)  fb_hash "$i"; ;;

	charrainbow3)
		charrainbow3 "$1" "$2" "$3" "$4"
		shift 4
		;;

	charrainbow)
		charrainbow "$1" "$2" "$3"
		shift 3
		;;

	print)
		printf "%s" "$1"
		shift
		;;

	echo)
		printf "%s\n" "$1"
		shift
		;;

	test)
		printf "%s\e(B\e[m\n" "$h"
		i=
		h=
		;;

	colors)
		echo "$colors"
		;;
	regenerate_config)
		regenerate_config
		;;
	*)
		error "Unknown mode: $i"
		;;
	esac
done
