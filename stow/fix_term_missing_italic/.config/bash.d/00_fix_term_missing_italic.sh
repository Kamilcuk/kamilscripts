
# https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/
if [[ "$({ tput sitm; } 2>/dev/null)" != "" ]]; then return; fi

case "$TERM" in
	screen-256color)
		tic "${BASH_SOURCE%/*}"/screen-256color-italic.terminfo
		export TERM=screen-256color-italic
		;;
	xterm-256color)
		tic "${BASH_SOURCE%/*}"/xterm-256color-italic.terminfo
		export TERM=xterm-256color-italic
		;;
esac
