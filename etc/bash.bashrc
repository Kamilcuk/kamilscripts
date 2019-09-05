#!/bin/bash

if [ -z "$PS1" -o -z "$BASH" -o -n "${POSIXLY_CORRECT+x}" ]; then
	return
fi

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

PS1=""
PS1+="$(color.sh -s reset)"
PS1+='$(ret=$?; if [ "$ret" -ne 0 ]; then color.sh -s bold yellow; fi; printf "$ret"; if [ "$ret" -ne 0 ]; then color.sh -s reset; fi) '
if test "$UID" -eq 0; then
	PS1+="$(color.sh -s bold red  )\u@$(hostname) $(color.sh -s blue)\$(pwd)$(color.sh -s reset)\n\[$(color.sh -s yellow)\]\\\$\[$(color.sh -s reset)\] "
else
	PS1+="$(color.sh -s bold green)\u@$(hostname) $(color.sh -s blue)\$(pwd)$(color.sh -s reset)\n\\\$ "
fi
export PS1

export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"

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
export TMP=/tmp
export TMPDIR=/tmp
mesg y

if ! test "$UID" -eq 0; then
  alias pacman='sudo pacman'
fi
alias pacmann='pacman --noconfirm'
alias yaourtn='yaourt --noconfirm'
alias yayn='yay --noconfirm'

alias ls='ls --color -F'
alias ping='ping -4'
alias l='ls -alF --color -h --group-directories-first'
alias o='less'

hist() { eval "history $(for i; do echo -n "|grep -a \"$i\""; done)"; }

qqnotifycomplete() { 
  echo "notifycomplete: last command exited with $?"
  while true; do
    paplay --volume=65536 /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null
    sleep 2 
  done
}

alias pmake='time nice make -j$(nproc) --load-average=$(nproc)'

export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"

