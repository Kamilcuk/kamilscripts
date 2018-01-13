#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))/pkg-archlinux
../makepkg.sh "$@"
sudo -u kamil makepkg -p ${1:-PKGBUILD} -i

