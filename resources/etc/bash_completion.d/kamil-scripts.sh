#!/bin/bash

if test "$PS1" && test "$BASH" && test -z ${POSIXLY_CORRECT+x} && test -r /etc/bash.bashrc; then
	. /usr/lib/kamil-scripts/bash.bashrc
fi

