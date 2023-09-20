#!/usr/bin/env bash

if [[ $- != *i* ]]; then return; fi

# https://stackoverflow.com/questions/4261876/check-if-bash-script-was-invoked-from-a-shell-or-another-script-application
# If connected with sudo or as child shell.
if ! hash ps 2>/dev/null || ! [[ $(ps -o stat= -p $$ 2>/dev/null) =~ s && -t 0 ]]; then return; fi

# If not connected via ssh.
#if [[ -z "${SSH_CLIENT:-}" && -z "${SSH_TTY:-}" && -z "${SSH_CONNECTION:-}" ]]; then

if ((BASHLVL)); then return; fi

if hash cal 2>/dev/null; then
	if hash tput 2>/dev/null; then tput setaf 2; fi
	cal -3m
	if hash tput 2>/dev/null; then tput sgr0; fi
fi

if hash fortune 2>/dev/null; then fortune; fi

if hash sed 2>/dev/null; then
	# Show screen and tmux detached sessions.
	if hash screen 2>/dev/null; then
		timeout 0.5 screen -list 2>/dev/null |
			sed '
			/Directory .* must have mode .*.$/d;
			/No Sockets found/{N;d};
			/This room is empty/d;
			/^[[:space:]]*$/d;
			s/^/screen: /' || :
		# | sed '/Detached/!d; s/^/screen: /'
	fi
	if hash tmux 2>/dev/null; then
		timeout 0.5 tmux ls 2>/dev/null |
			sed 's/^/tmux: /' || :
		# | sed '/(attached)/d; s/$/ (detached)/; s/^/tmux: /'
	fi
fi
