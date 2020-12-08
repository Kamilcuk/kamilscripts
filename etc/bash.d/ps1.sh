#!/bin/bash

# check if running interactively
case $- in *i*) return; ;; esac

#### PS1
PS1_setup() {
	if ! hash ,color >/dev/null 2>/dev/null; then
		,color() { :; }
	fi

	local tmp root noroot colors
	tmp="white reset bold yellow standout red blue green nostandout cyan"
	local $tmp
	declare -g PS1

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

	# ${var+expr} expands to expr is var is set, but empty
	if ((UID)); then 
		noroot=;
		unset root
	else
		unset noroot;
		root=;
	fi

	# {user:green/root:red}<username>@{rainbow}<hostname> {lightblue}/{blue}<dir>...\n$
	PS1=
	PS1+="\\[$reset\\]"
	PS1+='$(if ((ret = $?)); then printf '\''\[%s\]%s\[%s\] '\'' '\'"$bold$yellow"\'' "$ret" '\'"$reset"\''; fi)'
	PS1+="\\[$bold${root+$standout$red}${noroot+$green}\\]"
	PS1+="\u"
	PS1+="${root+\\[$nostandout\\]}"
	PS1+="@"
	if ((colors)) && hash ,color 2>/dev/null; then
		PS1+="$(,color -s sha1charrainbow3 "$HOSTNAME" | sed 's/\x1b\[[0-9;]*m/\\[&\\]/g')"
	else
		PS1+='\h'
	fi	 
	PS1+=' '
	# PS1+="\\[$blue\\]"
	# PS1+='\w'
	local printf
	printf="printf"
	if hash "/usr/bin/printf" 2>/dev/null && /usr/bin/printf "%q" 2>/dev/null >&1; then
		printf="/usr/bin/printf"
	elif hash "/bin/printf" 2>/dev/null && /bin/printf "%q" 2>/dev/null >&1; then
		printf="/bin/printf"
	fi
	PS1+='$('
	if "$printf" "%q" something 2>/dev/null >&2; then
	# check if %q is supported with printf
		PS1+="$printf"' "%q" "$PWD" | '
	else
		PS1+='<<<"$PWD" '
	fi
	PS1+='awk -F"/"'
		PS1+=' -vfront="\["'"$cyan"'"\]"'
		PS1+=' -vback="\["'"$blue"'"\]"'
		PS1+=' '\''{gsub("/", front "/" back)}1'\'
	PS1+=')'
	PS1+="\\[$reset\\]"
	PS1+=$'\n'
	PS1+="${root+\\[$red\\]}"
	PS1+='\$'
	PS1+="${root+\\[$reset\\]}"
	PS1+=' '
	export PS1

	unset printf
}
PS1_setup
unset -f PS1_setup

