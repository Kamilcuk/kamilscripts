#!/bin/sh
# kamilscripts ~/.profile

. ~/.config/kamilscripts/kamilscripts/etc/profile

for i in \
		"${XDG_CONFIG_HOME:-$HOME/.config}"/profile.d/*.sh \
		~/.profile_*
do
	if [ -e "$i" ]; then
		. "$i"
	fi
done
unset i

