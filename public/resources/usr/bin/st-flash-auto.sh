#!/bin/bash
set -euo pipefail
case "${1##*.}" in
bin) exec st-flash --format binary write "$1" "${2:-0x8000000}"; ;;
elf)
  tmp=$(mktemp --suffix=.hex)
  trap 'rm -f $tmp' EXIT
  arm-none-eabi-objcopy -O ihex "$1" "$tmp"
  st-flash --format ihex write "$tmp"
  rm -f $tmp
  trap '' EXIT
  ;;
hex) exec st-flash --format ihex write "$@"; ;;
*) echo "ERROR: File \"$1\" format not recognized. Must be .bin , .elf or .hex." >&2; exit 1; ;;
esac

