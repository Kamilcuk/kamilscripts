#!/bin/bash

# check if running interactively
if [ -z "$PS1" -o -z "$BASH" -o -n "${POSIXLY_CORRECT+x}" ]; then
	return
fi

# add some paths to path
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

appendpath '/bin'
appendpath '/sbin'
appendpath '/usr/lib/kamilscripts/bin'
unset appendpath
export PATH

if ! hash color.sh >/dev/null 2>/dev/null; then
	color.sh() { :; }
fi

# set the PS1
PS1=""
PS1+="$(color.sh -s reset)"
PS1+='$(ret=$?; if [ "$ret" -ne 0 ]; then color.sh -s bold yellow; fi; printf "$ret"; if [ "$ret" -ne 0 ]; then color.sh -s reset; fi) '
PS1+="$(if [ "$UID" -eq 0 ]; then color.sh -s standout bold red; else color.sh -s bold green; fi)"
PS1+="\u"
PS1+="$(if [ "$UID" -eq 0 ]; then color.sh -s nostandout; fi)"
PS1+="@"
#PS1+="$(color.sh -s "f#$(hostname | md5sum | cut -c-6)")\h "
PS1+="$(color.sh charrainbow $(hostname | md5sum | sed 's/.\{6\}\(.\{6\}\)\(.\{6\}\).*/\1 \2/') $(hostname))"
PS1+=' '
PS1+="$(color.sh -s blue)\w$(color.sh -s reset)"$'\n'
PS1+="$([ "$UID" -eq 0 ] && color.sh -s bold red)\\\$$([ "$UID" -eq 0 ] && color.sh -s reset) "
export PS1

# set some history variables
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="123:234:l:ls:[bf]g:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
# For good measure, make all history environment variables read-only.
readonly HISTSIZE
readonly HISTFILESIZE
readonly HISTCONTROL
readonly HISTIGNORE
readonly HISTFILE
readonly HISTFILESIZE

shopt -s histappend # append to history, dont overwrite
shopt -s cmdhist # multiple commands in one line

# set some environmental variables
export EDITOR="/bin/vim"
export VISUAL="/bin/vim"
export TMP=/tmp
export TEMP=/tmp
export TMPDIR=/tmp
mesg y

####################################################################

if [ -e /etc/arch-release ]; then
	p() {
		if hash yay 2>/dev/null; then
			nice ionice yay "$@"
		elif [ "$UID" -ne 0 ]; then
			nice ionice sudo pacman "$@"
		else
			nice ionice pacman "$@"
		fi
	}
	_completion_p() {
		if hash yay 2>/dev/null; then
			i=yay
		else
			i=pacman
		fi
		set -- "$i" "${@:2}"
		_xfunc $i _$i "$@"
	}
	complete -F _completion_p -o default p

	alias pn='p --noconfirm'
	complete -F _completion_p -o default pn

	if [ "$UID" -ne 0 ]; then
		alias pacmann='sudo pacman --noconfirm'
	else
		alias pacmann='pacman --noconfirm'
	fi
	complete -F _pacman -o default pacmann

	pupdate() {
		if hash yay 2>/dev/null; then
			nice ionice yay --noconfirm -Suy "$@"
		elif [ "$UID" -ne 0 ]; then
			nice ionice sudo pacman --noconfirm -Suy "$@"
		else
			nice ionice pacman --noconfirm -Suy "$@"
		fi
	}
	_completion_pupdate() {
		_xfunc pacman _pacman_pkg Qq
	}
	complete -F _completion_pupdate -o default pupdaate
	
fi

alias ping='ping -4'

alias ls='ls --color -F'
alias l='ls -alF --color -h --group-directories-first'
if declare -f _longopt >/dev/null; then 
	_complete_l() {
		set -- ls -alF --color -h --group-directories-first "${@:2}"
		_longopt "$@"
	}
	complete -F _complete_l l
fi

alias o='less'
if declare -f _longopt >/dev/null; then
	_complete_o() {
		set -- less "${@:2}"
		_longopt "$@"
	}
	complete -F _complete_o o
fi

hist() { eval "history $(for i; do echo -n "|grep -a \"$i\""; done)"; }

alias pmake='time nice ionice make -j$(nproc) --load-average=$(nproc)'

# https://wiki.archlinux.org/index.php/Makepkg
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

# https://stackoverflow.com/questions/749544/pipe-to-from-the-clipboard-in-bash-script
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -i -selection clipboard -o'

