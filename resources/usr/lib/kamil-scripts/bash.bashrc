#!/bin/bash

# ------------------- GLOBAL ----------------------
#[ -d /etc/bash_completion.d ] && . /etc/bash_completion.d/*

# colors
_RED="$(tput setaf 1 2>/dev/null)"
_GREEN="$(tput setaf 2 2>/dev/null)"
_BOLD="$(tput bold 2>/dev/null)"
_BLUE="$(tput setaf 4 2>/dev/null)"
_YELLOW="\[\033[33;1m\]"
_NORMAL="$(tput sgr0 2> /dev/null)"
# PS1
if  test "$UID" -eq 0 -a -t; then
  export PS1="$_YELLOW\$? ${_RED}$(hostname) ${_BOLD}${_BLUE}\w$_NORMAL\n\\$ "
else
  export PS1="$_YELLOW\$? ${_GREEN}\u@$(hostname) ${_BOLD}${_BLUE}\w$_NORMAL\n\\$ "
fi

export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export HISTSIZE=600000
export HISTCONTROL="ignorespace:erasedups"
alias l='ls -alF --color -h --group-directories-first'
alias o='less'
hist() { eval "history $( while [ $# -ne 0 ]; do echo -n " | grep \"\$$#\""; shift; done; )"; }

# ------------- local -----------------

if ! test "$UID" -eq 0 -a -t; then
        alias pacman='sudo pacman'
	alias pacmann='sudo pacman --noconfirm'
else
	alias pacmann='pacman --noconfirm'
fi
alias yaourtn='yaourt --noconfirm'

export PATH="$PATH:/home/users/kamil/bin"
export HISTFILE="$HOME/.bash_history"
export HISTIGNORE="123:234:l:ls:[bf]g:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear" # more
export VDPAU_DRIVER=r600
export SDL_AUDIODRIVER=alsa

# For good measure, make all history environment variables read-only.
typeset -r HISTCONTROL
typeset -r HISTFILE
typeset -r HISTFILESIZE
typeset -r HISTIGNORE
typeset -r HISTSIZE

shopt -s histappend # append to history, dont overwrite
shopt -s cmdhist # multiple commands in one line
export TMP=/tmp
export TMPDIR=/tmp
mesg y

alias ls='ls --color -F'
alias ping='ping -4'

qqhist() {
	history | grep -a "$*"
}
qqnotifycomplete() { 
  echo "notifycomplete: last command exited with $?"
  while true; do
    paplay --volume=65536 /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null
    sleep 2 
  done
}
priority_cpu_low()    { nice -n -100     "$@"; }
priority_cpu_normal() { nice -n -$(nice) "$@"; }
priority_cpu_high()   { nice -n 100      "$@"; }
priority_io_low()     { ionice -c 3      "$@"; }
priority_io_normal()  { ionice -c 0      "$@"; }
priority_io_high()    { ionice -c 1      "$@"; }

# parallel make
export NUMCPUS=$(grep -c '^processor' /proc/cpuinfo)
alias pmake='time nice make -j$NUMCPUS --load-average=$NUMCPUS'

