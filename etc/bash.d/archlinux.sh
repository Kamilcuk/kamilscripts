#!/bin/bash

if [[ ! -e /etc/arch-release ]]; then
	return
fi

if ((UID)); then
	alias pacman='sudo pacman'
fi

alias p=',pacman p'
alias pn=',pacman pn'
alias pupdate=',pacman pupdate'
alias pacmann=',pacman pacmann'
alias yayn=',pacman yayn'
alias pacman_autoremove=',pacman autoremove'


