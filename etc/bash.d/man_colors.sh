#!/bin/bash

if [[ $- != *i* ]]; then return; fi

# shellcheck disable=2155
if hash nvim 2>/dev/null; then
	export MANPAGER='nvim +Man!'
	export MANWIDTH=999
elif false && hash most 2>/dev/null; then
	export PAGER=most
elif hash less 2>/dev/null; then
	export LESS_TERMCAP_mb=$'\E[1m\E[32m'
	export LESS_TERMCAP_md=$'\E[1m\E[91m'
	export LESS_TERMCAP_me=$(tput sgr0)
	export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
	export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
	export LESS_TERMCAP_us=$'\E[4m\E[92m'
	export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
	export LESS_TERMCAP_mr=$(tput rev)
	export LESS_TERMCAP_mh=$(tput dim)
	export LESS_TERMCAP_ZN=$(tput ssubm)
	export LESS_TERMCAP_ZV=$(tput rsubm)
	export LESS_TERMCAP_ZO=$(tput ssupm)
	export LESS_TERMCAP_ZW=$(tput rsupm)
	export GROFF_NO_SGR=1         # For Konsole and Gnome-terminal
	export MANPAGER=less
fi

