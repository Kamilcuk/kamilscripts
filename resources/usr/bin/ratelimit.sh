#!/bin/bash
set -euo pipefail
export SHELLOPTS

NAME=ratelimit.sh

# Functions ###############################################

usage() {
	cat <<EOF
 $NAME [options]

Rate limit lines coming from the input and delimeter them.

Options:
 -t, --timeout=<number>            Output the buffer once timeout is reached. 
                                   In seconds, may be a floating number. 0 disables it. Default 5.
 -l, --lines=<number>              Output the buffer once the count of lines is reached. 
                                   0 disables the check. Default 5.
 -i, --input-separator=<char>      Input separator, default Line Feed "\n". Passed to read(1)
 -o, --output-separator=<string>   Output separator, default Start of Text "\x02". Passed to printf(1)
     --print-empty                 If set, when timeout expired and no lines are in buffer, 
                                   an output separator only is printed.
 -h, --help

Examples:
 cat /dev/urandom | $NAME -t 5

Written by Kamil Cukrowski (C) 2019
Licensed jointly under MIT and Beerware license
EOF

	if (($#)); then
		echo "ERROR:" "$@" >&2
		exit 1
	fi
}

ns() {
	date +%s%N;
}

assert() {
	if ! eval "$1"; then
		echo "Assertion '$1' failed" "$@" >&2
		exit 1
	fi
}

test() {
	i=0
	while true; do
		timeout=$((RANDOM%10?0:2)).$((RANDOM%10))
		sleep "$timeout"
		echo "$i $RANDOM $RANDOM $RANDOM $timeout"
		i=$((i+1))
	done | 
	tee >(sed 's/^/    IN: /' > /dev/stderr)
}

# Parse Arguments ##########################

if ! ARGS=$(getopt \
	--name "$NAME" \
	--options t:l:i:o:h \
	--longoptions timeout:,lines:,input-separator:,output-separator:,print-empty,help \
	-- "$@"
); then
	echo ERROR: getopt error >&2
	exit 1
fi
eval set -- "$ARGS"

maxtimeoutsec=5
maxlines=5
input_separator=$'\n'
output_separator=$'\x02'
print_empty=false

while (($#)); do
	case "$1" in
	-t|--timeout) maxtimeoutsec=$2; shift; ;;
	-l|--lines) maxlines=$2; shift; ;;
	-i|--input-separator) 
		IFS= read -rd '' input_separator < <(printf -- "$2") ||:
		shift
		;;
	-o|--output-separator) 
		IFS= read -rd '' output_separator < <(printf -- "$2") ||:
		shift
		;;
	--print-empty)
		print_empty=true
		;;
	-h|--help)
		usage;
		exit 0
		;;
	--) shift; break; ;;
	*) usage "Wrong argument:" "$1"; ;;
	esac
	shift
done

if (($#)); then
	if [ "$1" = "test" ]; then
		exec < <(test)
		output_separator="-------------"$'\n'
	else
		usage "Too many arguments"
	fi
fi

# Main ##########################

giga=1000000000
maxtimeoutns=$(<<<"scale=0; $maxtimeoutsec * $giga" bc)
maxtimeoutns=$(printf "%.0f" "$maxtimeoutns")

timeout_arg=()

while true; do
	chunk=""
	lines=0
	start=$(ns)
	stop=$((start + maxtimeoutns))

	while true; do

		if [ "$maxtimeoutns" != 0 ]; then
			now=$(ns)
			if (( now >= stop )); then
				break
			fi
			timeout=$(( stop - now ))
			timeout=$(<<<"scale=${#giga}; $timeout/$giga" bc)
			timeout_arg=(-t "$timeout")
		fi


		IFS= read -rd "$input_separator" "${timeout_arg[@]}" line && ret=$? || ret=$?
		assert "(( $ret == 0 || $ret > 128 ))"

		if (( ret == 0 )); then

			# read succeded
			chunk+=$line$'\n'

			if (( maxlines != 0 )); then
				lines=$((lines + 1))
				if (( lines >= maxlines )); then
					break
				fi
			fi

		elif (( ret > 128 )); then
			# read timeouted
			break;
		fi
	done

	if (( ${#chunk} != 0 )) || "$print_empty"; then
		printf "%s%s" "$chunk" "$output_separator"
	fi

done

