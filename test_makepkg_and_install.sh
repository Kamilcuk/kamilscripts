#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))/pkg-archlinux
sudo -u kamil makepkg -p PKGBUILD.test -c -i -f

