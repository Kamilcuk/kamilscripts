#!/bin/bash
set -euo pipefail

fatal() {
	echo "st-flash-auto: error:" "$@" >&2
	exit 2
}

if (($# == 0)); then
	cat <<EOF
Usage: st-flash-auto file [address]

Written by Kamil Cukrowski 2020
EOF
	exit 0
fi
if [[ ! -e "$1" ]]; then
	fatal "file does not exists:" "$1"
fi
if [[ ! -r "$1" ]]; then
	fatal "no permissions to read:" "$1"
fi

case "${1##*.}" in
bin)
	st-flash --format binary --reset write "$1" "${2:-0x8000000}";
	;;
elf)
	tmp=$(mktemp --suffix=.hex)
	trap 'rm -f $tmp' EXIT
	arm-none-eabi-objcopy -O ihex "$1" "$tmp"
	st-flash --format ihex --reset write "$tmp"
	rm -f "$tmp"
	trap '' EXIT
	;;
hex)
	st-flash --format ihex --reset write "$@";
	;;
*) 
	fatal "file format not recognized:" "$1" $'\n'"Must be .bin, .elf or .hex."
esac

