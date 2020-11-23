#!/bin/bash

# re-load profile
for _i in "$(dirname "$(readlink -f "$BASH_SOURCE")")"/profile.d/*.sh; do
	if [[ -e "$_i" ]]; then
		. "$_i"
	fi
done
unset _i

if [[ $- != *i* ]]; then return; fi

# load bash dropins
for _i in "$(dirname "$(readlink -f "$BASH_SOURCE")")"/bash.d/*.sh; do
	if [[ -e "$_i" ]]; then
		. "$_i"
	fi
done
unset _i


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

# Aliases

alias ping='ping -4'
alias ls='ls --color -F'
alias l='ls -alF --color -h --group-directories-first'
alias o='less'
alias rm='rm --preserve-root -I'

# https://stackoverflow.com/questions/749544/pipe-to-from-the-clipboard-in-bash-script
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -i -selection clipboard -o'

hist() { local args; for i; do args+=(-e "$i"); done; history | grep -a "${args[@]}"; }

