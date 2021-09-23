#!/bin/bash

name=$(basename "$0")

usage() {
	cat <<EOF
Usage: $name modulename

Print module parameters with values if loaded.

EOF
}
if ((!$#)); then
	usage
	exit
fi

m=$1
d=/sys/module/$m/parameters/
if [ ! -d "$d" ]; then
	fatal "Module $m not loaded"
fi

modinfo "$m" | sed -n 's/^parm: *//p' |
sort |
awk -F: -v "d=$d" -v OFS=':' '{ f = d $1; getline v < f; print $0, v}'

