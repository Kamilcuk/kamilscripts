#!/bin/bash

# check if running interactively
if [[ $- != *i* ]]; then return; fi

#### PS1
PS1_setup() {
	if ! hash color.sh >/dev/null 2>/dev/null; then
		color.sh() { :; }
	fi

	local tmp root noroot colors
	tmp="white reset bold yellow standout red blue green nostandout cyan"
	local $tmp
	declare -g PS1

	IFS=$'\x01' read -r $tmp < <(
		color.sh -s --separator=$'\x01' $tmp
	) ||:

	colors=0
	if hash tput color.sh 2>/dev/null; then
		if ! colors=$(tput colors 2>/dev/null); then
			colors=0
		fi
	fi

	if [ "$colors" -lt 256 ]; then
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
	if hash md5sum color.sh 2>/dev/null && [ "$colors" -ge 256 ]; then
		#PS1+="\\[$(color.sh -s "f#$(<<<"$HOSTNAME" md5sum | cut -c-6)")\\]\h "
		#PS1+="\\[$(color.sh -s charrainbow $(<<<"$HOSTNAME" md5sum | cut -c-12 | sed 's/.\{6\}/& /g') "$(hostname)")\\]"
		PS1+="$(color.sh -s charrainbow3 $(<<<"$HOSTNAME" md5sum | cut -c-18 | sed 's/.\{6\}/& /g') "$HOSTNAME" | sed 's/\x1b\[[0-9;]*m/\\[&\\]/g')"
	else
		PS1+='\h'
	fi	 
	PS1+=' '
	# PS1+="\\[$blue\\]"
	# PS1+='\w'
	PS1+='$(/bin/printf "%q" "$PWD" | awk -F"/"'
		PS1+=' -vfront="\["'"$(printf "%q" "$cyan")"'"\]"'
		PS1+=' -vback="\["'"$(printf "%q" "$blue")"'"\]"'
		PS1+=' '\''{gsub("/", front "/" back)}1'\'
	PS1+=')'
	PS1+="\\[$reset\\]"
	PS1+=$'\n'
	PS1+="${root+\\[$red\\]}"
	PS1+='\$'
	PS1+="${root+\\[$reset\\]}"
	PS1+=' '
	export PS1
}
PS1_setup
unset -f PS1_setup

