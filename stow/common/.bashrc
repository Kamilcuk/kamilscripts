#!/bin/bash
# kamilscripts ~/.bashrc

# . ,bash_qprofile.sh 1start

. ~/.config/kamilscripts/kamilscripts/etc/bash.bashrc

for i in \
		"${XDG_CONFIG_HOME:-$HOME/.config}"/bash.d/*.sh \
		~/.bashrc_*
do
	if [[ -e "$i" ]]; then
		. "$i"
	fi
done
unset i

# . ,bash_qprofile.sh 1stop_auto

