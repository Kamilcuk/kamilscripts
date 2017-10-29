#!/bin/bash
set -euo pipefail
cd "$(dirname $(dirname $(readlink -f "$0")))"/pkg-archlinux

export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"
(
  set -x
  makepkg -c "$@"
)

