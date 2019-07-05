#!/bin/bash

if [ -z "$PS1" -o -z "$BASH" -o -n "${POSIXLY_CORRECT+x}" ]; then
	return
fi

tputex() {
	for i; do
		case "$i" in
		help) 
			echo "Usage: tputex [bold|underline|standout|normal|reset|red|green|yellow|blue|magenta|cyan|white]..."
			return 1
			;;
		bold)           tput bold; ;;
		underline)      tput smul; ;;
		standout)       tput smso; ;;
		normal|reset)   tput sgr0; ;;
		black)          tput setaf 0; ;;
		red)            tput setaf 1; ;;
		green)          tput setaf 2; ;;
		yellow)         tput setaf 3; ;;
		blue)           tput setaf 4; ;;
		magenta)        tput setaf 5; ;;
		cyan)           tput setaf 6; ;;
		white)          tput setaf 7; ;;
		*) echo "tputex: Error: Unknown option $i" >&2; return 1; ;;
		esac
	done
}

if ! ( test -t 1 && colors=$(tput colors 2>/dev/null) && test -n "$colors" && test "$colors" -ge 8 ); then
	tputex() { :; }
fi

PS1="\$(ret=\$?; if test \"\$ret\" -ne 0; then tputex bold yellow; else tputex normal; fi; printf \"\$ret\") "
if test "$UID" -eq 0; then
	PS1+="$(tputex bold red  )\u@$(hostname) $(tputex blue)\$(pwd)$(tputex normal)\n\[$(tputex yellow)\]\\\$\[$(tputex reset)\] "
else
	PS1+="$(tputex bold green)\u@$(hostname) $(tputex blue)\$(pwd)$(tputex normal)\n\\\$ "
fi
export PS1

export PATH="$PATH:/bin:/sbin"
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

