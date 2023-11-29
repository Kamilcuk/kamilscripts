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
export HISTFILE=~/.bash_historymy
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="123:234:l:ls:bg:fg:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
export HISTTIMEFORMAT='%FT%T '
# For good measure, make all history environment variables read-only.
readonly HISTSIZE
readonly HISTFILESIZE
readonly HISTFILE

shopt -s histappend # append to history, dont overwrite
shopt -s cmdhist # multiple commands in one line

# Aliases

alias ls='ls --color -F'
alias o='less -R'
alias rm='nice -n 40 ionice -c 3 rm --preserve-root=all --one-file-system -I'
alias mv='nice -n 40 ionice -c 3 mv -i'
# shellcheck disable=2285
alias +='pushd .'
alias -- -='popd'
alias ..='cd ..'
alias ...='cd ../..'
alias cd..='cd ..'
alias beep='echo -en "\007"'
alias l='command l'
alias ll='ls -l -F --color -h --group-directories-first'
alias watch='watch -c -d -n 1'
for _i in \
		make \
		cmake \
		tar \
		du \
		find \
		cargo \
		zip \
		clang \
		gcc \
		cc \
		g++ \
		ld \
		mv \
		rm \
		cp \
		rsync \
; do
	if ! alias "${_i}" >/dev/null 2>&1; then
		# shellcheck disable=2139
		alias "${_i}"="nice -n 40 ionice -c 3 $_i"
	fi
done
unset _i

# When an interactive shell that is not a login shell is started, Bash reads and executes commands from ~/.bashrc
for _i in \
		"${XDG_CONFIG_HOME:-~/.config}"/bash.d/*.sh \
		~/.bashrc_*
do
	if [[ -e "$_i" ]]; then
		# shellcheck disable=SC1090
		. "$_i"
	fi
done
unset _i

,hash() {
	hash "$@" 2>/dev/null
}
