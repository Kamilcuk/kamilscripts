#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))/pkg-archlinux
set -x
rm -v -f *.pkg.tar.xz
sudo -u kamil makepkg -p ${1:-PKGBUILD} -c
if hash namcap >&/dev/null; then namcap *.pkg.tar.xz; fi

