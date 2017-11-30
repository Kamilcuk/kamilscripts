#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))
./makepkg_and_install.sh PKGBUILD.test

