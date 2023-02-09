#!/bin/sh

if [[ $- != *i* ]]; then return; fi

if [[ -z "$KCDIR" ]]; then
	echo "bc.sh: KCDIR not found" >&2
	return
fi

# https://unix.stackexchange.com/questions/609618/is-it-possible-to-save-bc-command-line-history/609700#609700
if hash rlwrap 2>/dev/null; then
	bc() { LC_ALL=C rlwrap -a -H "$HOME"/.cache/bc_history bc "$@"; }
else
	bc() { LC_ALL=C command bc "$@"; }
fi
# https://stackoverflow.com/questions/22621488/is-there-an-rc-file-for-the-command-line-calculator-bc
BC_ENV_ARGS=" -q -l $(echo "$KCDIR"/etc/bc.d/*.bc)"
export BC_ENV_ARGS

