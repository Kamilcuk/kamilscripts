#!/bin/bash

if [ -z "$PS1" -o -z "$BASH" -o -n "${POSIXLY_CORRECT+x}" ]; then
	return
fi

# colors
_RED="$(tput setaf 1 2>/dev/null)"
_GREEN="$(tput setaf 2 2>/dev/null)"
_BOLD="$(tput bold 2>/dev/null)"
_BLUE="$(tput setaf 4 2>/dev/null)"
_YELLOW="\[\033[33;1m\]"
_NORMAL="$(tput sgr0 2> /dev/null)"

# PS1
if test "$UID" -eq 0 -a -t; then
  export PS1="$_YELLOW\$? ${_RED}$(hostname) ${_BOLD}${_BLUE}\w$_NORMAL\n\\$ "
else
  export PS1="$_YELLOW\$? ${_GREEN}\u@$(hostname) ${_BOLD}${_BLUE}\w$_NORMAL\n\\$ "
fi

export PATH="$PATH:/bin:/sbin"
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"

export HISTSIZE=600000
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE=\
"123:234:l:ls:[bf]g:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
# For good measure, make all history environment variables read-only.
typeset -r HISTSIZE
typeset -r HISTCONTROL
typeset -r HISTIGNORE
typeset -r HISTFILE
typeset -r HISTFILESIZE

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

