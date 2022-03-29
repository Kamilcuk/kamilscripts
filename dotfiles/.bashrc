#!/bin/bash
# kamilscripts ~/.bashrc

# . ,bash_qprofile.sh 1start

. ~/.kamilscripts/etc/bash.bashrc

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

if [[ "$HOSTNAME" == "leonidas" && "$USER" = "kamil" ]]; then
	# kcukrowski
	#export ANSIBLE_VAULT_PASSWORD_FILE=~/ncbj/password.txt
	#export ANSIBLE_VAULT_IDENTITY=kcukrowski
	export ANSIBLE_VAULT_PASSWORD_FILE=~/ncbj/ansible_password.txt
	export ANSIBLE_STDOUT_CALLBACK=debug
	export ANSIBLE_DISPLAY_ARGS_TO_STDOUT=1
fi

