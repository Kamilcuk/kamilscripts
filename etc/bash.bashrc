#!/bin/bash

# function hist is declared in bash.d/hist.sh
if declare -f ,hash >/dev/null 2>&1; then
	# already sourced - just ignore
	# hist function is defined below
	return
fi

# re-load profile if not already sourced
#if [[ ! -d "$KCDIR" ]]; then
	. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/profile
#fi

if [[ $- != *i* ]]; then return; fi

# When an interactive shell that is not a login shell is started, Bash reads and executes commands from ~/.bashrc
for _i in \
		"${KCDIR}"/etc/bash.d/*.sh \
		"${XDG_CONFIG_HOME:-~/.config}"/bash.d/*.sh \
		~/.bashrc_*
do
	if [[ -e "$_i" ]]; then
		# shellcheck disable=SC1090
		. "$_i"
	fi
done
unset _i

L_var_is_readonly() { ! (eval "$1=") 2>/dev/null; }
L_hash() { hash "$@" 2>/dev/null; }

# set some history variables, export and make them read only
export HISTSIZE=
export HISTFILESIZE=
export HISTFILE=~/.bash_historymy
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="123:234:l:ls:bg:fg:exit:su:su -:history:hist:reboot:poweroff:mnsstat:kotekkc:rm *:wipefs *:mkfs *: *:pwd:clear"
if ! L_var_is_readonly HISTTIMEFORMAT; then
	export HISTTIMEFORMAT='%FT%T '
fi

shopt -s histappend # append to history, dont overwrite
shopt -s cmdhist # multiple commands in one line
set +H # disable history expansion

# Aliases

alias ls='ls --color -F'
alias o='less -R'
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

_pre=""
if L_hash nice; then
	_pre="nice -n 40 "
fi
if L_hash ionice; then
	_pre+="ionice -c 3 "
fi
alias rm="${_pre}rm --preserve-root=all --one-file-system -I"
alias mv="${_pre}mv -i"
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
		alias "${_i}"="${_pre}$_i"
	fi
done
unset _i _pre

,hash() {
	hash "$@" 2>/dev/null
}

export TIMEFORMAT="real=%6lR user=%6lU system=%6lS"
