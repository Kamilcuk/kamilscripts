
if [[ $- != *i* ]]; then return; fi

# https://stackoverflow.com/questions/4261876/check-if-bash-script-was-invoked-from-a-shell-or-another-script-application
# If connected with sudo or as child shell.
if ! [[ $(ps -o stat= -p $$ 2>/dev/null) =~ s && -t 0 ]]; then return; fi

# If not connected via ssh.
if [[ -z "${SSH_CLIENT:-}" && -z "${SSH_TTY:-}" && -z "${SSH_CONNECTION:-}" ]]; then
	# Show calendar and a fortune.
	if hash cal 2>/dev/null; then
		if hash ,color 2>/dev/null; then ,color green; fi
		cal -3m
		if hash ,color 2>/dev/null; then ,color reset; fi
	fi
	if hash fortune 2>/dev/null; then fortune; fi
fi

# Show screen and tmux detached sessions.
if hash screen 2>/dev/null; then
	screen -list | sed '/Detached/!d; s/^/screen: /'
fi
if hash tmux 2>/dev/null; then
	tmux ls 2>/dev/null | sed '/(attached)/d; s/$/ (detached)/; s/^/tmux: /'
fi

