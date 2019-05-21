#!/bin/bash
set -xeuo pipefail

pacman -Sy --needed --noconfirm base-devel git sudo
chown -R nobody:nobody .
chmod +w /etc/sudoers
printf "nobody ALL=(ALL) NOPASSWD:"" ALL" >> /etc/sudoers
chmod -w /etc/sudoers

pushd pkg/archlinux >/dev/null
sudo -u nobody makepkg -f --syncdeps --noconfirm

ls -l *.pkg.tar.xz

popd

if (($# > 0)); then
	mkdir -v -p "$1"
	mv -v pkg/archlinux/*.pkg.tar.xz "$1"/
fi

