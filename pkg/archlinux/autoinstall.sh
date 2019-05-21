#!/bin/bash
set -xeuo pipefail

tee -a /etc/pacman.conf <<EOF
# BEGIN kamilscript MANAGED BLOCK
[kamcuk]
Server = https://kamcuk.gitlab.io/archlinux-repo/
SigLevel = Never
# END kamilscript MANAGED BLOCK
EOF

pacman -Sy kamilscripts

