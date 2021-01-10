
# https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/
if ! hash tput 2>/dev/null >&2; then return; fi; # no ncurses, no point
# if [[ "$({ tput sitm; } 2>/dev/null)" != "" ]]; then return; fi

newterm=""
case "$TERM" in
screen-256color)
	newterm=screen-256color-italic
	;;
xterm-256color)
	newterm=xterm-256color-italic
	;;
esac

if [[ -n "$newterm" ]]; then
	# Regenerate all custom terminals if not generated already.
	if hash tic 2>/dev/null >&1; then
		for i in "$(dirname "$BASH_SOURCE")"/*.terminfo; do 
			if [[ -e "$i" && ! -e "$HOME/.terminfo/${i:0:1}/$i" ]]; then
				tic "$i"
			fi
		done
	fi
	if [[ -e "$HOME/.terminfo/${newterm:0:1}/$newterm" ]]; then
		alias su="TERM=$TERM su"
		alias sudo="TERM=$TERM sudo"
		export TERM="$newterm"
	fi
fi
unset newterm

