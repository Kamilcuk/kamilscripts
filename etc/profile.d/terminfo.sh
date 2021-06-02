
# https://rsapkf.xyz/blog/enabling-italics-vim-tmux
if hash tic 2>/dev/null >&2 && hash infocmp 2>/dev/null >&2; then
	(
	ihas() { { infocmp "$1"; } 2>/dev/null >&2; }
	if ihas xterm+256color && ! ihas xterm-256color-italic; then cat <<EOF
xterm-256color-italic|xterm with 256 colors and italic,
    sitm=\E[3m, ritm=\E[23m,
    use=xterm-256color,
EOF
	fi
	if ihas xterm+tmux && ihas screen && ! ihas tmux; then cat <<EOF
tmux|tmux terminal multiplexer,
    ritm=\E[23m, rmso=\E[27m, sitm=\E[3m, smso=\E[7m, Ms@,
    use=xterm+tmux, use=screen,
EOF
	fi
	if ihas xterm+256setaf && ihas tmux && ! ihas tmux-256color; then cat <<EOF
tmux-256color|tmux with 256 colors,
	use=xterm+256setaf, use=tmux,
EOF
	fi; ) |
	tic -x -
fi


