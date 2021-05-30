
# Older dircolors doesn't support properly TERM glob mathing from configuration
# So I'll match it myself with case.

if
	hash dircolors 2>/dev/null >&1 &&
	hash envsubst 2>/dev/null >&2 &&
	[ -r "$KCDIR"/etc/dircolors ] &&
	case "$TERM" in
	Eterm|ansi|*color*|con[0-9]*x[0-9]*|cons25|console|cygwin|dtterm|gnome|hurd|jfbterm|konsole|kterm|linux|linux-c|mlterm|putty|rxvt*|screen*|st|terminator|tmux*|vt100|xterm*) true; ;;
	*) false; ;;
	esac
then
	eval "$(envsubst <"$KCDIR"/etc/dircolors | dircolors -b -)"
fi

