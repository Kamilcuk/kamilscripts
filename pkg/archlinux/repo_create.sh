#!/bin/bash
set -xeuo pipefail
repo="$1"
pkgsdir="$2"
pkgs=$(find "$pkgsdir" -type f -name '*.pkg.tar.xz')
mkdir -p $(dirname "$repo")
repo-add -n "$repo".db.tar.xz $pkgs

