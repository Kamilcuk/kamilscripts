#!/bin/bash
set -xeuo pipefail
repo=$(readlink -f "$1")
cd $(dirname "$0")
mkdir -p $(dirname "$repo")
repo-add "$repo".db.tar.xz "$(ls -t *.pkg.tar.xz | head -1)"

