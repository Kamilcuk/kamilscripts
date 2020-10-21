[[ $- != *i* ]] && return

# https://stackoverflow.com/questions/4261876/check-if-bash-script-was-invoked-from-a-shell-or-another-script-application
# do not show calendar when su-ing
[[ ! $(ps -o stat= -p $$) =~ s && "$SHLVL" == 1 ]] && return

# Put your local functions and aliases herea
if hash cal 2>/dev/null && [[ $(cal --version 2>&1) =~ "util-linux" ]]; then
	hash color.sh 2>/dev/null && color.sh green
	cal -3m
	hash color.sh 2>/dev/null && color.sh reset
fi
hash fortune 2>/dev/null && fortune

