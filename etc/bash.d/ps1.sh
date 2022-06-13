#!/bin/bash

# check if running interactively
if [[ $- =~ *i* ]]; then return; fi

_kc_prompt_setup() {
	if ! hash ,color >/dev/null 2>/dev/null; then
		,color() { :; }
	fi

	local reset=$'\E[m'
	local bold=$'\E[1m'
	local standout=$'\E[3m'
	local nostandout=$'\E[23m'
	local red=$'\E[31m'
	local green=$'\E[32m'
	local yellow=$'\E[33m'
	local blue=$'\E[34m'
	local cyan=$'\E[36m'
	local white=$'\E[37m'
	local back_magenta=$'\E[45m'

	local colors=0
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

	local pre=""

	# Detect virtualization with the help of systemd
	local virt
	if
		hash systemd-detect-virt 2>/dev/null >&2 && {
			{ virt=$(systemd-detect-virt) && [[ -n "$virt" && "$virt" != 'none' ]] ;} ||
			{ systemd-detect-virt -q -r 2>/dev/null && virt='chroot' ;} ||
			{ systemd-detect-virt -q --private-users 2>/dev/null && virt='usernm' ;}
		}
	then
		pre+="\\[$bold$red\\]$virt\\[$reset\\] "
	fi

	if [[ -n "${NIX_PROFILES:-}" && -r '/nix/' && -d '/nix/' ]]; then
		pre+="\\[$back_magenta$white\\]nix\\[$reset\\] "
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
		one=$'\001'
		two=$'\002'
		for i in \
			bold standout nostandout yellow red blue green cyan reset \
			hostname one two
		do
			echo "s~%$i%~${!i}~g"
		done
	)"
	tmp="$(
		sed "$tmp" <<'EOF'
_kc_prompt_command() {
	# Running in a subshell, so don't caring about parent shell.

	# Use:
	#   ${root+something} for root
	#   ${root-something} for user
	if ((UID)); then
		unset root
	else
		root=
	fi

	if (($1)); then
		printf "\001%bold%%yellow%\002$1\001%reset%\002 "
	fi
	printf "\001%bold%${root+%standout%%red%}${root-%green%}\002$USER${root+\001%nostandout%\002}@%hostname%\001%reset%%bold%\002 %s\001%reset%${root+%red%%bold%}\002" "$(
		printf "%q" "$PWD" | sed "
			s~^$'\(.*\)'$~%one%%reset%%two%$'%one%%bold%%two%\1%one%%reset%%two%'~
			s@/@%one%%cyan%%two%/%one%%blue%%two%@g
		"
	)"
	# When listing all functions with declare -F, turn off the color.
	: "%reset%"
}
EOF
	)"
	eval "$tmp"
	PS1="\[$reset\]$pre\$(_kc_prompt_command \"\$?\")\n\\$\[$reset\] "
}

_kc_prompt_setup


