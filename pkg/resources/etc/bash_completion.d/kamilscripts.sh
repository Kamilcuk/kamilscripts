#!/bin/bash

if [ -n "$PS1" -a -n "$BASH" -a -z ${POSIXLY_CORRECT+x} -a -r /usr/lib/kamilscripts/bash.bashrc ]
then
    . /usr/lib/kamilscripts/bash.bashrc
fi
