#!/bin/bash

# https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/

if ! hash tput 2>/dev/null >&2; then return; fi; # no ncurses, no point
# if [[ "$({ tput sitm; } 2>/dev/null)" != "" ]]; then return; fi

# Regenerate all custom terminals if not generated already.
if hash tic 2>/dev/null >&1 && [[ -n "$KCDIR" ]]; then
	for src in "$KCDIR"/etc/terminfo/*.terminfo; do
		if [[ ! -e "$src" ]]; then break; fi
		file=$(basename -- "$src" .terminfo)
		dest="$HOME/.terminfo/${file:0:1}/$file"
		if [[ ! -e "$dest" || "$src" -nt "$dest" ]]; then
			if ! tic "$src"; then
				return
			fi
		fi
	done
	unset src file dest
fi

# Fix terminal if I want to
newterm=""
case "$TERM" in
screen-256color|xterm-256color)
	newterm=$TERM-italic
	;;
esac
if [[ -n "$newterm" && -e "$HOME/.terminfo/${newterm:0:1}/$newterm" ]]; then
	if ((UID)); then
		if ! alias su 2>/dev/null >&2; then
			# shelcheck disable=2139
			alias su="TERM=$TERM su"
		fi
		if ! alias sudo 2>/dev/null >&2; then
			# shelcheck disable=2139
			alias sudo="TERM=$TERM sudo"
		fi
	fi
	TERM="$newterm"
fi
unset newterm

