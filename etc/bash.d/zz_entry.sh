
if [[ $- != *i* ]]; then return; fi
# if connected via ssh, be empty
if [[ -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" || -n "${SSH_CONNECTION:-}" ]]; then return; fi

# https://stackoverflow.com/questions/4261876/check-if-bash-script-was-invoked-from-a-shell-or-another-script-application
# do not show calendar when su-ing
if ! [[ $(ps -o stat= -p $$) =~ s && -t 0 ]]
then return; fi

# Put your local functions and aliases herea
if hash cal 2>/dev/null; then
	if hash ,color 2>/dev/null; then ,color green; fi
	cal -3m
	if hash ,color 2>/dev/null; then ,color reset; fi
fi
if hash fortune 2>/dev/null; then fortune; fi

