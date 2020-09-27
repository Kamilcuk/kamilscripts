[[ $- != *i* ]] && return

# Put your local functions and aliases herea
if hash cal 2>/dev/null && [[ $(cal --version 2>&1) =~ "util-linux" ]]; then
	hash color.sh 2>/dev/null && color.sh green
	cal -3m
	hash color.sh 2>/dev/null && color.sh reset
fi
hash fortune 2>/dev/null && fortune

