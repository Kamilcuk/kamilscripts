#!/bin/bash
set -xeuo pipefail
repo=$(readlink -f "$1")
pkgs=$(find "$2" -type f -name '*.pkg.tar.xz')
cd $(dirname "$0")
mkdir -p $(dirname "$repo")
repo-add "$repo".db.tar.xz $pkgs

