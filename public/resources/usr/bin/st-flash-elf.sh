#!/bin/bash
tmp=$(mktemp --suffix=.hex)
trap 'rm -f $tmp' EXIT
arm-none-eabi-objcopy -O ihex "$1" "$tmp"
st-flash --format ihex write "$tmp"
rm -f $tmp
trap '' EXIT
