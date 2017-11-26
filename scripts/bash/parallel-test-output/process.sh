#!/bin/bash

MAX=${1:-10}
log() {
	echo -ne "\r"
	printf "$@"
}
work() { 
	local i LEN=20
	for ((i=0; i <= $LEN; ++i)); do
		log "%4s %10s: [%${LEN}s] extracting" "$$" "$1" "$(printf "%${LEN}s" $(yes '#' | head -n $i | tr -d '\n') | rev)"
		sleep 0.$(( RANDOM % MAX ))
	done
	log "%20s: [%${LEN}s] finished" "$1" "$(yes '#' | head -n $LEN | tr -d '\n')"
}
work $MAX

