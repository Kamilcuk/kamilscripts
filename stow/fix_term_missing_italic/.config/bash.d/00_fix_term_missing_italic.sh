
# https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/
if ! hash tput 2>/dev/null >&2; then return; fi; # no ncurses, no point
if [[ "$({ tput sitm; } 2>/dev/null)" != "" ]]; then return; fi

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
	if 
		[[ -e "$HOME/.terminfo/${newterm:0:1}/$newterm" ]] || 
		{ hash toe 2>/dev/null >&2 && { toe -a | grep -q "^$newterm\s\+" ;} ;} ||
		{ hash tic 2>/dev/null >&2 && tic "$(dirname "$BASH_SOURCE")"/"$newterm".terminfo ;}
	then
		export TERM="$newterm"
	fi
fi
unset newterm

