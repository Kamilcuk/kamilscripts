
if [[ $- != *i* ]]; then return; fi

# https://unix.stackexchange.com/questions/609618/is-it-possible-to-save-bc-command-line-history/609700#609700
if hash rlwrap 2>/dev/null; then
	bc() { rlwrap -a -H "$HOME"/.cache/bc_history bc "$@"; }
fi
# https://stackoverflow.com/questions/22621488/is-there-an-rc-file-for-the-command-line-calculator-bc
BC_ENV_ARGS=" -q -l $(
	cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"/.. &&
	find "$PWD"/bc.d/ -name '*.bc' -exec printf "%q " {} +
)"
export BC_ENV_ARGS

