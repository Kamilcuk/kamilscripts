#!/bin/bash
set -euo pipefail
cd $(dirname $(readlink -f $0))/pkg-archlinux
sudo -u kamil makepkg -c -i -f

