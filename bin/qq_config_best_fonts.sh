#!/bin/bash
set -xeuo pipefail
export SHELLOPTS

echo '==> Installing needed packages <=='
sudo pacman -S --needed --noconfirm ttf-dejavu ttf-liberation

echo
echo '==> Configuring fonts presets <=='
sudo ln -vsf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -vsf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -vsf /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

echo
echo '==> Creating default font configuration to DejaVu Sans fonts <=='
if [ -e /etc/fonts/local.conf ]; then
	echo "/etc/fonts/local.conf exists - bailing out of fear!" >&2
	exit 1
fi
sudo tee /etc/fonts/local.conf <<-'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match>
        <edit mode="prepend" name="family"><string>DejaVu Sans</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>DejaVu Serif</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>sans-serif</string></test>
        <edit name="family" mode="assign" binding="same"><string>DejaVu Sans</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>monospace</string></test>
        <edit name="family" mode="assign" binding="same"><string>DejaVu Sans Mono</string></edit>
    </match>
</fontconfig>
EOF

if hash gdk-pixbuf-query-loaders >/dev/null ;then
	echo
	echo '==> Updating gdk pixbuf <=='
	sudo gdk-pixbuf-query-loaders --update-cache
fi


