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

# set the PS1
PS1=""
PS1+="$(color.sh -s reset)"
PS1+='$(ret=$?; if [ "$ret" -ne 0 ]; then color.sh -s bold yellow; fi; printf "$ret"; if [ "$ret" -ne 0 ]; then color.sh -s reset; fi) '
if test "$UID" -eq 0; then
	PS1+="$(color.sh -s bold red  )\u@$(hostname) $(color.sh -s blue)\$(pwd)$(color.sh -s reset)\n\[$(color.sh -s yellow)\]\\\$\[$(color.sh -s reset)\] "
else
	PS1+="$(color.sh -s bold green)\u@$(hostname) $(color.sh -s blue)\$(pwd)$(color.sh -s reset)\n\\\$ "
fi
export PS1

# set some history variables
export HISTSIZE=600000
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="123:234:l:ls:[bf]g:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
# For good measure, make all history environment variables read-only.
readonly HISTSIZE
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

# my most common aliases
if ! test "$UID" -eq 0; then
  alias pacman='sudo pacman'
fi
alias p=pacman
alias pn='pacman --noconfirm'
alias pacmann='pacman --noconfirm'
alias yayn='yay --noconfirm'
alias ls='ls --color -F'
alias ping='ping -4'
alias l='ls -alF --color -h --group-directories-first'
alias o='less'

hist() { eval "history $(for i; do echo -n "|grep -a \"$(printf "%q" "$i")\""; done)"; }

alias pmake='time nice make -j$(nproc) --load-average=$(nproc)'

export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

