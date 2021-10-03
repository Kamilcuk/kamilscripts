#!/bin/bash

# function hist is declared in bash.d/hist.sh
if declare -f hist >/dev/null 2>&1; then
	# already sourced - just ignore
	# hist function is defined below
	return
fi

# re-load profile if not already sourced
if [[ -z "$KCDIR" ]]; then
	. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/profile
fi

if [[ $- != *i* ]]; then return; fi

# load bash dropins
for _i in "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/bash.d/*.sh; do
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
alias mv='mv -i'
# shellcheck disable=2285
alias +='pushd .'
alias -- -='popd'
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias beep='echo -en "\007"'
alias l='command l'
alias ll='ls -l -F --color -h --group-directories-first'
alias make='nice make'
alias cmake='nice cmake'

