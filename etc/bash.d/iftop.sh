#!/bin/bash

if ((UID)) && [[ -e ~/.iftoprc ]] && hash sudo 2>/dev/null >&2; then
	alias iftop='sudo iftop -c ~/.iftoprc'
fi
