#!/bin/bash

cp /etc/pacman.conf /tmp
printf "[kamcuk]\nServer = https://kamcuk.gitlab.io/archlinux-repo/\nSigLevel = Never\n" >> /etc/pacman.conf
pacman -Sy --noconfirm kamil-scripts
tmp=$(head -n -3 /etc/pacman.conf); echo "$tmp" > /etc/pacman.conf
printf "\nInclude = /usr/lib/kamil-scripts/pacman.conf\n" >> /etc/pacman.conf

