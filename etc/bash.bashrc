#!/bin/bash

if declare -f hist 2>/dev/null >/dev/null; then
	# already sourced - just ignore
	# hist function is defined below
	return
fi

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

alias ls='ls --color -F'
alias o='less'
alias rm='rm --preserve-root -I'

