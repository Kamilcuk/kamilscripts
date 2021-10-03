#!/bin/bash
set -xeuo pipefail
repo="$1"
pkgsdir="$2"
pkgs=$(find "$pkgsdir" -type f -name '*.pkg.tar.*')
mkdir -p "$(dirname "$repo")"
cp -va "$pkgs" "$(dirname "$repo")"
repo-add -n "$repo".db.tar.xz "$pkgs"

