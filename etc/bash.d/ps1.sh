#!/bin/bash

# check if running interactively
if [[ $- =~ *i* ]]; then return; fi

_kc_prompt_setup() {
	if ! hash ,color >/dev/null 2>/dev/null; then
		,color() { :; }
	fi

	local tmp colors
	tmp="reset bold standout nostandout yellow red blue green cyan"
	local $tmp

	IFS=' ' read -r $tmp < <(,color -s --separator=' ' $tmp) ||:

	colors=0
	if hash tput 2>/dev/null; then
		if ! colors=$(tput colors 2>/dev/null); then
			colors=0
		fi
	fi

	if ((colors < 256)); then
		nostandout=
		standout=
	fi

	# {user:green/root:red}<username>@{rainbow}<hostname> {lightblue}/{blue}<dir>...\n$

	# Detect virtualization with the help of systemd
	local virt
	if hash systemd-detect-virt 2>/dev/null >&2 &&
		{ virt=$(systemd-detect-virt) && [[ -n "$virt" && virt != 'none' ]] ;} ||
		{ systemd-detect-virt -q -r 2>/dev/null && virt=chroot ;} ||
		{ systemd-detect-virt -q --private-users 2>/dev/null && virt=usernm ;}
	then
		virt="\\[$bold$red\\]$virt\\[$reset\\] "
	else
		virt=""
	fi

	local hostname
	if ((colors)) && hash ,color 2>/dev/null; then
		hostname="$(,color -s sha1charrainbow3 "$HOSTNAME" | sed 's/\x1b\[[0-9;]*m/\x01&\x02/g')"
	else
		hostname='$HOSTNAME'
	fi

	eval "$(
		export $tmp virt hostname
		envsubst "$(sed 's/ / $/g' <<<" $tmp virt hostname")" <<'EOF'
_kc_prompt_command() {
	# Running in a subshell, so don't caring about parent shell.

	# Use:
	#   ${root+something} for root
	#   ${root-soemthing} for user
	if ((UID)); then unset root; else root=; fi

	if (($1)); then
		printf "\001$bold$yellow\002$1\001$reset\002 "
	fi
	printf "\001$bold${root+$standout$red}${root-$green}\002$USER${root+\001${nostandout}\002}@$hostname\001$reset$bold\002 $(
		printf "%q" "$PWD" | sed "
			/^$'.*'$/{
				s/^$'/\x01$reset\x02$'\x01$bold\x02/;
				s/'$/\x01$reset\x02'/;
			}"'
			s@\\@\\\\@g; s@/@\x01$cyan\x02/\x01$blue\x02@g
		'
	)\001$reset\002${root+$'\001'$red$'\002'}"
}
EOF
)"
	PS1="\[$reset\]$virt\$(_kc_prompt_command \$?)\n\$\[$reset\] "
}

_kc_prompt_setup


