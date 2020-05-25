#!/bin/bash

if ! { _parse_args_eval=$({
# MARK #########################################################################
set -euo pipefail

name=$(basename "$BASH_SOURCE")

# I find /bin/printf better at qouting
# altough slower, so only for debugging)
printf() {
	/bin/printf "$@"
}

test() {
	export PARSE_ARGS_TEST=true
	alphabet='! "#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
	f() (
		. ,bash_parse_args.sh \
			-n "$alphabet" \
			--pre "$(cat <<-EOF
			Usage: $alphabet [options] file

			This module ensures a particular line is in file
			_
			EOF
			)" \
			--post "$(cat <<-EOF
			Examples:
			  $alphabet -l "/my/ultimate/config.sh" /etc/bash.bashrc

			Written by Kamil Cukrowski 2019
			_
			EOF
			)" \
			--wrap column \
			-- \
			-d --delete delete "$alphabet" \
			-l --line line: "Specify the exact line" \
			'' --other-opt onlylong "Option with really reallly really really long description string that has to be broken on multiple lines to work proprtly" \
			-o --other-opt onlylong "Option with really reallly really really long description string that has to be broken on multiple lines to work proprtly" \
			-r --regex regex: "Line specified with regex, matchd with grep" \
			-V --validate validate: "Run this command after substitution" \
			-O '' longonly "Only long option" \
			'' --only-long onlylong "Only short option" \
			-O '' longonly: "Only long option" \
			'' --only-long onlylong: "Only short option" \
			-O '' longonly:: "Only long option" \
			'' --only-long onlylong:: "Only short option" \
			-- "$@"
		declare -p delete line regex validate
	)
	f -d -l a -r b -V c -- e
	f -h
	f --shit
	exit 3
}

usage() {
	cat <<EOF
Usage: $name [options] args...

The ultimate solution for parsing bash command line options.

Options:
   -h --help            Display help text and exit.
      --longhelp        See longer description of arguments.
   -n --name progname   The name that will be used to report errors.
   -p --prefix text     The prefix text to add to help message.
   -s --suffix text     The suffix text to add to help message.
   -q --quiet           Disable error reporting.
   -Q --quiet-output    Do not generate normal output.
                        Errors are still reported unless -q.
   -w --wrap mode       Set wrapping mode, can be 'column'.
      --test            Run unit tests and exit.

Arguments list may optionally start with '+' or '-'.
Arguments is a list of groups of 5 arguments:
  shortopt longopt type variable description

Written by Kamil Cukrowski
Licensed jointly under Beerware License and MIT License.
EOF
}

longhelp() {
	cat <<EOF
Arguments list may start with the first argument being 
'+' or '-'. They are interpreted the same as first character
by getopt(1) in section SCANNING MODES.

Arguments is a list of groups of 5 arguments:
  <shortopt> - A short option that set's the variable
              or empty if short option should not be used.
  <longopt> - The long option that set's the variable 
              or empty if long option should not be used.
  <type> - A string that:
    - if empty, means option doesn't take an argument
    - if starts with a single doublepoint, means the option
      takes an argument
    - if starts with a double doubleponit, means the option
      take an optional argument.
    - Doublepoints (or nothing) are optionally followed by
      by the type of variable. Types are listed below.
  <variable> - The variable to set.
  <description> - The description of the variable.

Types:
  BOOL - This is the type of the variable that takes no option.
         The variable will be set to the string 'true' or 'false'.

EOF
}

args=$(getopt -n "$name" -o hn:p:s:qQw: \
	-l help,longhelp,name:,prefix:,suffix:,quier,quiet-output,wrap:,test -- "$@")
name=$0
pre=""
suf=""
wrap=
pass_args=()
while (($#)); do
	case "$1" in
	-h|--help) usage; exit; ;;
	-n|--name) ="$2"; shift; ;;
	-p|--prefix) pre="${2%_}"; shift; ;;
	-s|--suffix) suf="${2%_}"; shift; ;;
	
	-w|--wrap) wrap=$2; shift; ;;
	   --test) test; ;;
	--) shift; break; ;;
	esac
	shift;
done

init=""
usage=$'-h\x01--help\x01Print this text and exit\n'
cases=""
shortopts="h"
longopts="help"

while (($#)); do
	if [[ "$1" == '--' ]]; then
		shift
		break
	fi
	shortopt=${1#-}
	longopt=${2#--}
	varname=${3%%:*}
	varopt=${3//*::*/::}
	if [[ "$varopt" != "::" ]]; then
		varopt=${3//*:*/:}
		if [[ "$varopt" != ':' ]]; then
			varopt=
		fi
	fi
	vartype=${3##*:}
	desc=$4
	shift 4

	if [[ "$varopt" != :* ]]; then
		init+="$varname=false"$'\n'
	else
		init+="$varname="$'\n'
	fi

	if [[ -n "$shortopt" ]]; then
		usage+="-$shortopt"$'\x01'
		shortopts+="$shortopt$varopt"
		cases+="-$shortopt|"
	else
		usage+=$'\x01'
	fi
	if [[ -n "$longopt" ]]; then
		longopts+=",$longopt$varopt"
		cases+="--$longopt"
		usage+="--$longopt"
	fi
	case "$varopt" in
	:) 
		if [[ -n "$longopt" ]]; then
			usage+="=STR"
		else
			usage+=" STR"
		fi
		;;
	::)
		if [[ -n "$longopt" ]]; then
			usage+="[=STR]"
		else
			usage+=" [STR]"
		fi
		;;
	esac
	usage+=$'\x01'"$desc"$'\n'

	cases="${cases%|}"
	cases+=") $(printf %q "$varname")="
	if [[ -n "$varopt" ]]; then
		cases+="\"\$2\"; shift; "
	else
		cases+="true; "
	fi
	cases+=";;"$'\n'
done

# internal unique uuid
uuid=c29d6e0a-6540-4f71-908b-339b085d7104

# convert usage to readable text
usage="$(
case "${wrap:-smart}" in
none)
	sed 's/^\([^\x01]*\)\x01\([^\x01]*\)\x01\(.*\)$/  \1\x01\2\x01\3/' |
	column -t -s $'\x01' -o ' ' -W3
	;;
column)
	sed 's/^\([^\x01]*\)\x01\([^\x01]*\)\x01\(.*\)$/  \1\x01\2\x01\3/' |
	column -t -s $'\x01' -o ' ' -W3
	;;
smart|*)
	sed 's/^\([^\x01]*\)\x01\([^\x01]*\)\x01\(.*\)$/  \1\x01\2\x01\x02\n\x01\x01\3/' |
	column -t -s $'\x01' -o ' ' | fmt -c -s -w $(tput cols) |
	sed '/\x02$/{N;s/\x02\n *//}'
	;;
esac <<<"$usage"
)"$'\n'


# compose output
output=
output+="$init"'
_parse_args_getopt_ret=0
_parse_args_args=$(getopt \
		-n '"$(printf %q "$name")"' \
		-o '"$(printf %q "$shortopts")"' \
		-l '"$(printf %q "$longopts")"' \
		-- "$@") || _parse_args_getopt_ret=$?
case "$_parse_args_getopt_ret" in
0) ;;
1) exit 1; ;;
2) echo '"$(printf %q "$name")"'": ,parse_args.sh: Error: Internal error" >&2; exit 2; ;;
3) echo '"$(printf %q "$name")"'": Error: getopt internal error" >&2; exit 2; ;;
*) echo '"$(printf %q "$name")"'": Error: unhandled error" >&2; exit 2; ;;
esac
unset _parse_args_getopt_ret
eval set -- "$_parse_args_args"
unset _parse_args_args
while (($#)); do
	case "$1" in
	-h|--help)
		cat <<'"'$uuid'"$'\n'

if [[ -n "$pre" ]]; then 
	output+="$pre"$'\n'
else
	output+="Usage: $name [options] [args...]"$'\n'
fi
output+="Options:"$'\n'
output+="$usage"
if [[ -n "$suf" ]]; then
	output+=$'\n'"$suf"
fi
output+=$'\n'"$uuid"$'\n'
output+='
		exit
		;;
'"$(sed 's/^/\t/' <<<"${cases%%$'\n'}")"'
	--) shift; break; ;;
	*) echo '"$(printf %q "$name")"'": ,parse_args.sh: Error: Internal error" >&2; exit 2; ;;
	esac
	shift
done
'

if ! bash -c "$output" "$name: ,parse_args.sh: bash" -h >/dev/null; then
	echo "$name: ,parse_args.sh: Error: Super internal error" >&2
	exit 2
fi

printf "%s\n" "$output" >&3

# MARK #########################################################################
} 3>&1 1>&4 ) ;} 4>&1 ; then
	exit 1
fi

_parse_args_BOOL() {
	local tmp
	if tmp=$(locale LC_MESSAGES); then
		tmp="^[+1yY]"$'\n'
		tmp="^[-0nN]"$'\n'
		tmp="yes"$'\n'
		tmp="no"$'\n'
	fi

	local yesptrn noptrn yesword noword
	{
		IFS= read -r yesptrn
		IFS= read -r noptrn
		IFS= read -r yesword
		IFS= read -r noword
	} <<<"$tmp"
	
	case "$2" in
       	${yesptrn##^}) echo true; ;;
        ${noptrn##^}) echo false; ;;
        * ) echo "Answer ${yesword} / ${noword}."; exit 1; ;;
    esac
}

while [[ "$1" != '--' ]]; do
	shift
done
shift
while [[ "$1" != '--' ]]; do
	shift
done
shift

eval "$_parse_args_eval"

unset _parse_args_eval
