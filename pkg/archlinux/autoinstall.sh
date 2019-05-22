#!/bin/bash
set -xeuo pipefail

tee -a /etc/pacman.conf <<EOF
# BEGIN kamilscript MANAGED BLOCK
[kamilrepo]
Server = https://kamcuk.gitlab.io/archlinux/
SigLevel = Never
# END kamilscript MANAGED BLOCK
EOF

pacman -Sy kamilscripts

