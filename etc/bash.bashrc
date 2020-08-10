#!/bin/bash

# check if running interactively
if [ -z "$PS1" -o -z "$BASH" -o -n "${POSIXLY_CORRECT+x}" ]; then
	return
fi


#### Path

appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
	    ;;
    esac
}

appendpath '/bin'
appendpath '/sbin'
appendpath '/usr/lib/kamilscripts/bin'
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
unset appendpath
export PATH

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
	PS1+='$(printf "%q" "$PWD" | awk -F"/"'
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

#### Bash variables

# set some history variables
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="123:234:l:ls:[bf]g:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
export HISTTIMEFORMAT='%FT%T '
# For good measure, make all history environment variables read-only.
readonly HISTSIZE
readonly HISTFILESIZE

shopt -s histappend # append to history, dont overwrite
shopt -s cmdhist # multiple commands in one line

# set some environmental variables
export EDITOR="/bin/vim"
export VISUAL="/bin/vim"
export TMP=/tmp
export TEMP=/tmp
export TMPDIR=/tmp
export COUNTRY=PL
mesg y

#### Common env variables

# https://wiki.archlinux.org/index.php/Makepkg
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

# https://stackoverflow.com/questions/22621488/is-there-an-rc-file-for-the-command-line-calculator-bc
BC_ENV_ARGS="$(readlink -f "${BASH_SOURCE[0]}")"
export BC_ENV_ARGS="${BC_ENV_ARGS%/*}/bcrc"

# Aliases

alias ping='ping -4'
alias ls='ls --color -F'
alias l='ls -alF --color -h --group-directories-first'
. alias_complete.sh -s l ls
alias o='less'
. alias_complete.sh -s o less
alias rm='rm --preserve-root=all -I'

# https://stackoverflow.com/questions/749544/pipe-to-from-the-clipboard-in-bash-script
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -i -selection clipboard -o'

hist() { eval "history $(for i; do echo -n " | grep -a $(printf "%q" "$i")"; done)"; }

#### Load my files

_backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'

tmp=$(dirname "$BASH_SOURCE")/bash.d
if [[ -d "$tmp" && -r "$tmp" && -x "$tmp" ]]; then
	_backup_glob='@(#*#|*@(~|.@(bak|orig|rej|swp|dpkg*|rpm@(orig|new|save))))'
	for i in "$tmp"/*; do
		if [[ -r "$i" && "${i##*/}" != @($_backup_glob|Makefile*) ]]; then
			. "$i"
		fi
	done
	unset i _backup_glob
fi
unset tmp

