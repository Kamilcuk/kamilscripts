#!/bin/bash

################################## functions ###############

usage() {
	cat << EOF
USAGE:
	$(basename $0) dd (read|write) <disc> [dd_args]
	$(basename $0) bonnie++ <folder_path> [bonnie_args]
	$(basename $0) zcov <disc> [zcov_args]
	$(basename $0) find_best_dd_blocksize <disc>

Enviromental variables:
	OUTPUTFILE=$(basename $0).$(date '+%Y-%m-%dT%H:%M:%S').txt
		Wyjsciowy plik w tego testu
	TEST=false
		jeśli true, wtedy nie zapisuje nic do OUTPUTFILE
		oraz odpala taki testowy szybki benchmark
EOF
}

_stopervalue=""
stoperstart() {
	_stopervalue=$(date +%s%N)
}
stoperstop() {
	echo $((_stopervalue - $(date +%s%N) ))
}

find_best_dd_blocksize() {
	local disc=$1
	local out=()
	local testfile=$(mtemp)
	local bss=( 1k 2k 4k 8k 16k 32k 64k 128k 256k 512k 1M 2M 4M 8M )
	dd if=/dev/urandom of=$testfile bs=4k count=128
	trap 'rm $testfile' EXIT
	for bs in "${bss[@]}"; do
		echo ============= Testing block size  = $bs =================
		stoperstart
		dd if=$testfile of=$disc bs=$bs
		sync
		out+=( $(stoperstop) )
		echo ============== EOF Testing block size = $bs ==============
	done
	for i in $(seq 1 ${#bss[*]}); do
		echo ${out[$i]} ${bss[$i]}
	done | sort | tac
	rm $testfile
	trap '' EXIT
}

############################### main ######################

TEST=${TEST:-false}
OUTPUTFILE=${OUTPUTFILE:-}

case "$1" in
dd)
	case "$2" in
	read)
		dd if=$3 of=/dev/null $4
		;;
	write)
		dd if=/dev/zero of=$3 $4
		;;
	*)
		echo "ERROR - bad argument - '$2'"
		exit 1
	;;
bonnie++)
	bonnie++ -d "$2" -u root -g root
	sync
	;;
zcov)
	zcov $2
	;;
find_best_dd_blocksize)
	find_best_dd_blocksize
	;;
*)
	echo "ERROR - bad argument '$1'."
	exit 1
	;;
esac