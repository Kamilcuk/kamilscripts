#!/bin/sh
if hash luarocks 2>/dev/null; then
	if _i=$(luarocks path); then
		eval "$_i"
	fi
	unset _i
fi
