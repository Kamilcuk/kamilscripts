#!/bin/sh

export PAPERSIZE=a4
if [ -r "$KCDIR"/etc/papersize ]; then
	export PAPERCONF="$KCDIR"/etc/papersize
fi

