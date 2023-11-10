#!/bin/sh

case "$-" in *i*) ;; *) return ;; esac

# https://unix.stackexchange.com/questions/609618/is-it-possible-to-save-bc-command-line-history/609700#609700
bc() {
	# https://stackoverflow.com/questions/22621488/is-there-an-rc-file-for-the-command-line-calculator-bc
	if [ -d "${KCDIR:-}" ]; then
		BC_ENV_ARGS=" -q -l $(echo "$KCDIR"/etc/bc.d/*.bc)"
	fi
	if hash rlwrap 2>/dev/null; then
		BC_ENV_ARGS="$BC_ENV_ARGS" LC_ALL=C rlwrap -a -H ~/.cache/bc_history bc "$@"
	else
		BC_ENV_ARGS="$BC_ENV_ARGS" LC_ALL=C command bc "$@"
	fi
}

