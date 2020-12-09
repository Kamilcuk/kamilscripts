#!/bin/bash

if [[ $- != *i* ]]; then return; fi

hist() {
	{
		printf "%s\n" "$@"
		printf '\x00\n'
		history
	} | awk '
	/^\000$/{ endargs=1 }
	!endargs{ patterns[$0]; next }
	{
		for (pattern in patterns) if (!match($0, pattern)) next
		print
	}
	'  -
}


