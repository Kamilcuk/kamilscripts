
if hash dircolors 2>/dev/null >&1 && [[ -r "$KCDIR"/etc/dircolors ]]; then
	eval "$(dircolors -b "$KCDIR"/etc/dircolors)"
fi

