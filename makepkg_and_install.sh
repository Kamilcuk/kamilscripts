#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))/pkg-archlinux
rm -v -f *.pkg.tar.xz
sudo -u kamil makepkg -p ${1:-PKGBUILD} -c
namcap *.pkg.tar.xz
sudo -u kamil makepkg -p ${1:-PKGBUILD} -i

