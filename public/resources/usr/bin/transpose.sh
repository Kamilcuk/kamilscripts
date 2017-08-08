#!/bin/bash

usage() { 
	cat <<EOF

Usage:
	transpose.sh [options] [<file>....]

Transpose input.

Options:
 -s, --separator=<string>         possible table delimeter
 -o, --output-separator=<string>  output separator
 -h, --help                       display this help and exit
 -V, --version                    output version information and exit

Written by Kamil Cukrowski 2017. Under Beerware license.
EOF
}

OPTS=$(getopt -n "transpose.sh" -o s:o:hV --long separator,output-separator,help,version -n 'parse-options' -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- $OPTS

while true; do
    case "$1" in
        -s | --separator ) separator="$2"; shift; shift ;;
        -o | --output-separator ) outputseparator="$2"; shift; shift ;;
        -h | --help ) usage; exit ;;
        -V | --version ) usage; exit ;;
        --) shift; break ;;
        *) break ;;
    esac
done

awk '
BEGIN { 
    FS="'"${separator:- }"'"
    OUTFS="'"${outputseparator:- }"'"
}
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str OUTFS a[i,j]
        }
        print str
    }
}' "$@"
