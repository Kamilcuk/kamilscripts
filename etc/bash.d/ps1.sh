#!/bin/bash

# check if running interactively
if [[ $- =~ *i* ]]; then return; fi

_kc_prompt_setup() {
	if ! hash ,color >/dev/null 2>/dev/null; then
		,color() { :; }
	fi

	local ncolors colors
	ncolors="reset bold standout nostandout yellow red blue green cyan"
	local $ncolors

	IFS=' ' read -r $ncolors < <(,color -s --separator=' ' $ncolors) ||:

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
	if
		hash systemd-detect-virt 2>/dev/null >&2 && {
			{ virt=$(systemd-detect-virt) && [[ -n "$virt" && virt != 'none' ]] ;} ||
			{ systemd-detect-virt -q -r 2>/dev/null && virt='chroot' ;} ||
			{ systemd-detect-virt -q --private-users 2>/dev/null && virt='usernm' ;}
		}
	then
		virt="\\[$bold$red\\]$virt\\[$reset\\] "
	else
		virt=""
	fi

	local hostname
	if ! {
			((colors)) && hash ,color 2>/dev/null &&
			hostname="$(,color -s sha1charrainbow3 "$HOSTNAME" 2>/dev/null | sed $'s/\x1b\\[[0-9;]*m/\x01&\x02/g')" &&
			[[ -n "$hostname" ]]
		}
	then
		hostname="$HOSTNAME"
	fi

	local tmp
	tmp="$(
		for i in $ncolors hostname; do
			echo "s~%$i%~${!i}~g"
		done
	)"
	tmp="$(
		sed "$tmp" <<'EOF'
_kc_prompt_command() {
	# Running in a subshell, so don't caring about parent shell.

	# Use:
	#   ${root+something} for root
	#   ${root-soemthing} for user
	if ((UID)); then unset root; else root=; fi

	if (($1)); then
		printf "\001%bold%%yellow%\002$1\001%reset%\002 "
	fi
	printf "\001%bold%${root+%standout%%red%}${root-%green%}\002$USER${root+\001%nostandout%\002}@%hostname%\001%reset%%bold%\002 %s\001%reset%${root+%red%%bold%}\002" "$(
		one=$'\001'
		two=$'\002'
		printf "%q" "$PWD" | sed "
			/^$'.*'$/{
				s/^$'/${one}%reset%${two}$'${one}%bold%${two}/;
				s/'$/${one}%reset%${two}'/;
			}
			"'s@\\@\\\\@g'"
			s@/@${one}%cyan%${two}/${one}%blue%${two}@g
		"
	)"
	# When listing all functions with declare -F, turn off the color.
	: "%reset%"
}
EOF
	)"
	eval "$tmp"
	PS1="\[$reset\]$virt\$(_kc_prompt_command \$?)\n\\$\[$reset\] "
}

_kc_prompt_setup


