#!/bin/bash
set -euo pipefail

# functions ################################################### 

usage() {
	cat <<EOF
Usage:  
	netcattarpipe.sh [OPTIONS] out <hostname> <port> <source>...
		Compresses sources using tar+gzip pipe and netcats it to hostname:port
	netcattarpipe.sh [OPTIONS] in  <port> <destination>
		Receives compressed stream on port and uncompresses it to destination directory.
	netcattarpipe.sh [OPTIONS] inraw <port> <destination>
		Receiving compressed stream on port and saves it to destination.

Options:
	-s 	- Don't pass verbose flag -v to tar and netcat.
	-h 	- Print this help and exit.
	-t OPT	- Pass additional option OPT to tar command. This option is stacked.
	-n OPT	- Pass additional option OPT to nc command. This option is stacked.

Example:
	For ex. to copy files from directory /a/b on host1 to directory /c/b/ on host2:
	First on host2 run 'netcattarpipe.sh in 10000 /c/b/' , then
	on host1 run 'netcattarpipe.sh out host2 10000 /a/b/'

Written by Kamil Cukrowski 2017. Under MIT license.
EOF
	exit 1
}

error() { echo "$@" >&2; }

test() {
	$0 -h || true
	temp=$(mktemp -d)
	temp2=$(mktemp -d)
	trap 'rm -rf $temp $temp2' EXIT
	echo 123 > $temp/123
	$0 -s -t -v -n -v in 10000 $temp2 &
	$0 -s -t -v -n -v out localhost 10000 $temp
	wait
	if [ "$(cat $temp2/123)" != "123" ]; then
		error 'Error if [ "$(cat $temp2/$(basename $temp)/123)" != "123" ]; then'
	fi
	echo "test end"
	exit 0
}

# input ################################################

if [ $# -lt 1 ]; then usage; fi
verbose=true
taropts=()
ncopts=()
while getopts ':sht:n:' opt; do
	case "$opt" in
	s) verbose=false ;;
	h) usage ;;
	t) taropts+=( "$OPTARG" ) ;;
	n) ncopts+=( "$OPTARG" ) ;;
	\?) error "Invalid option: -$OPTARG"; usage; exit 1; ;;
	:) error "Option -$OPTARG requires an argument."; usage; exit 1;  ;;
	esac
done
shift $((OPTIND-1))

if $verbose; then
	taropts+=( '-v' )
	ncopts+=( '-v' )
fi

# main ###################################################

if [ $# -lt 3 ]; then error "Not enough arguments."; usage; fi
case "$1" in
out)
	if [ $# -lt 4 ]; then error "Not enough arguments."; usage; fi
	ncopts+=( "$2" "$3" )
	shift 3
	set -x
	tar "${taropts[@]}" -z -c -f - "$@" | nc -4 "${ncopts[@]}"
	;;
inraw)
	OUT=$(readlink -f "$3")
	set -x;
	nc -4 "${taropts[@]}" -l "$2" > "$OUT"
	;;
in)
	OUT=$(readlink -f "$3")
	set -x;
	nc -4 "${ncopts[@]}" -l "$2" | tar "${taropts[@]}" -z -x -f -p - -C "$OUT";
	;;
test)
	test 
	;;
*)
	error "Wrong mode used. Mode must be one of out, inraw or in."
	usage
	;;
esac



