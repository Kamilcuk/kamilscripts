
# https://rsapkf.xyz/blog/enabling-italics-vim-tmux
if hash tic 2>/dev/null >/dev/null; then
	tic -x - <<EOF
xterm-256color-italic|xterm with 256 colors and italic,
    sitm=\E[3m, ritm=\E[23m,
    use=xterm-256color,

tmux|tmux terminal multiplexer,
    ritm=\E[23m, rmso=\E[27m, sitm=\E[3m, smso=\E[7m, Ms@,
    use=xterm+tmux, use=screen,

tmux-256color|tmux with 256 colors,
    use=xterm+256setaf, use=tmux,
EOF
fi


