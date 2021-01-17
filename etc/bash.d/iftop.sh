
if ((UID)) && [[ -e "$HOME"/.iftoprc ]] && hash sudo 2>/dev/null >&2; then
	alias iftop="sudo iftop -c $HOME/.iftoprc"
fi
