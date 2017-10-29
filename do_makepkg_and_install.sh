#!/bin/bash
set -euo pipefail
sudo -u kamil $(dirname $(readlink -f $0))/pkg-archlinux/makepkg.sh -i -f

