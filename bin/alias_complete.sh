#!/bin/bash

# Private Functions ##########################################################

_aLiAs_CoMpLeTe__usage() {
      cat <<'EOF'
Usage: 
	alias_complete.sh [options] name command [args...]
	source alias_complete.sh name command [args]

Aliases autocompletion scripts of alias with the name "name"
to command "command [args...]".
Tries to handle all arguments and COMP_* variables.

Options:
	-h --help        - Print this help and exit.
	-a --with-alias  - Also print alias='command args...'.
	--longopt        - Alias this command to _longopt autocompletion.
	--shortopt       - Alias this command to _shortopt autocompletion.
	-s --silent      - Silence the output. Don't show any output except success.
	   --unittest    - Test the script

Usage examples:
	- alias l='ls -la'
	  source alias_complete.sh l ls
	- alias pS='pacman -S --noconfirm'
	  source alias_complete.sh pS pacman -S --noconfirm
	- Or just:
	  source alias_complete.sh -a pS pacman -S --noconfirm

WARNING:
  This script declares symbols available at parent scope.
  It is sourced for _speed_.
  All external symbols that should persist after script returns are 
  	only 3 or 4 functions inside _aLiAs_CoMpLeTe_::* namespace.
  All private symbols that should be unset before this script returns are within
  	_aLiAs_CoMpLeTe__* namespace.
  The script sets shopt -s extglob


Written by Kamil Cukrowski
Licensed jointly under MIT License and Beerware License.
EOF
}

_aLiAs_CoMpLeTe__clearenv() {
	# shellcheck disable=SC2154
	unset "${!_aLiAs_CoMpLeTe__@}"
	# shellcheck disable=SC2046
	unset -f $(declare -F | sed -n '/_aLiAs_CoMpLeTe__/s/^declare -f //p')
}

_aLiAs_CoMpLeTe__fatal() {
	declare -g _aLiAs_CoMpLeTe__silent
	if ! "$_aLiAs_CoMpLeTe__silent"; then
		echo "alias_complete.sh: ERROR:" "$@" >&2
	fi
	_aLiAs_CoMpLeTe__clearenv
}

_aLiAs_CoMpLeTe__run_unittests() {
	local err
	err=false

	err() {
		err=true
		echo "alias_complete.sh: ERROR: $1" >&2
	}
	assert() {
		if ! eval "$2"; then
			err "$1"
		fi
	}
	run() {
		bash -c 'set -euo pipefail -o errexit; '"$1"
	}

	local tmp

	# shellcheck disable=SC2016
	tmp=$(run 'source alias_complete.sh l ls; echo "${!_aLiAs_CoMpLeTe__@}"')
	assert "$LINENO" "(($? == 0))"
	# shellcheck disable=SC2016
	assert "$LINENO" '[[ -z "$tmp" ]]'

	# shellcheck disable=SC2016
	tmp=$(run 'source alias_complete.sh l ls;
			echo $(declare -F | sed -n '\''/_aLiAs_CoMpLeTe__/s/^declare -f //p'\'')')
	assert "$LINENO" "(($? == 0))"
	# shellcheck disable=SC2016
	assert "$LINENO" '[[ -z "$tmp" ]]'

	# shellcheck disable=SC2016
	tmp=$(run 'source alias_complete.sh l ls; 
		declare -F | sed -n '\''/_aLiAs_CoMpLeTe_/s/^declare -f //p'\''')
	assert "$LINENO" "(($? == 0))"
	# shellcheck disable=SC2016
	assert "$LINENO" '[[ -n "$tmp" ]]'

	if ! "$err"; then
		echo "SUCCESS"
	fi
}

# Parse arguments ###########################################################

_aLiAs_CoMpLeTe__shortopt=false
_aLiAs_CoMpLeTe__longopt=false
_aLiAs_CoMpLeTe__withalias=false
_aLiAs_CoMpLeTe__silent=false
_aLiAs_CoMpLeTe__unittest=false
while (($#)); do
	case "$1" in
	-h|--help) _aLiAs_CoMpLeTe__usage; exit 0; ;;
	-a|--with-alias) _aLiAs_CoMpLeTe__withalias=true; ;;
	--longopt) _aLiAs_CoMpLeTe__longopt=true; ;;
	--shortopt) _aLiAs_CoMpLeTe__shortopt=true; ;;
	-s|--silent) _aLiAs_CoMpLeTe__silent=true; ;;
	--unittest) _aLiAs_CoMpLeTe__unittest=true; ;;
	--) shift; break; ;;
	-*) _aLiAs_CoMpLeTe__fatal "Unknown option: $1"; return 2; ;;
	*) break; ;;
	esac
	shift
done

if "$_aLiAs_CoMpLeTe__unittest"; then
	if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
		_aLiAs_CoMpLeTe__fatal "For unittests to run, do not source this script"
		return 2
	fi
	_aLiAs_CoMpLeTe__run_unittests
	exit "$?"
fi

# We need to be sourced
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	_aLiAs_CoMpLeTe__fatal "This script has to be sourced"
	exit 2
fi

if (($# < 1)); then
	_aLiAs_CoMpLeTe__usage >&2
	_aLiAs_CoMpLeTe__fatal "No alias name specified"
	return 2
fi
if [[ -z "$1" ]]; then
	_aLiAs_CoMpLeTe__fatal "First argument is empty"
	return 2
fi
if "$_aLiAs_CoMpLeTe__longopt" && "$_aLiAs_CoMpLeTe__shortopt"; then
	_aLiAs_CoMpLeTe__fatal "The --shortopt and --longopt cannot be used together. --shortopt includes --longopt"
	return 2
fi
if ( "$_aLiAs_CoMpLeTe__longopt" || "$_aLiAs_CoMpLeTe__shortopt" ) && 
		"$_aLiAs_CoMpLeTe__withalias"; then
	_aLiAs_CoMpLeTe__fatal "The --with-alias must be used without --shortopt not --longopt. To which command shoud we alias?"
	return 2
fi

# Exported functions #################################################

shopt -s extglob

_aLiAs_CoMpLeTe_::shortopt() {
	if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
		# shelcheck disable=SC1091
		if ! . "/usr/share/bash-completion/bash_completion"; then
			echo "complete_alias: Sourcing /usr/share/bash-completion/bash_completion failed" >&2
			return 2
		fi
	fi

	# shellcheck disable=SC2034
    local cur prev words cword split
    _init_completion -s || return

	case "${prev,,}" in
    	--help|--usage|--version)
        	return
            ;;
    	--!(no-*)dir*)
        	_filedir -d
        	return
            ;;
    	--!(no-*)@(file|path)*)
        	_filedir
        	return
            ;;
    	--+([-a-z0-9_]))
			local argtype
        	argtype=$(LC_ALL=C $1 --help 2>&1 |
	    	command sed -ne "s|.*$prev\[\{0,1\}=[<[]\{0,1\}\([-A-Za-z0-9_]\{1,\}\).*|\1|p")
        	case ${argtype,,} in
            	*dir*)
                	_filedir -d
                	return
                    ;;
            	*file*|*path*)
                	_filedir
                	return
                    ;;
        	esac
        	;;
    esac

    $split && return

    # shellcheck disable=SC2207
	COMPREPLY=( $(compgen -W "$(
     	LC_ALL=C "$1" --help 2>&1 |
     	command tr ' ' '\n' |
     	command grep -x -- '-[-A-Za-z0-9]\+\(=.*\)\?' |
     	command cut -d= -f2- |
     	command sort -u
    )" -- "$cur") )
}

_aLiAs_CoMpLeTe_::longopt() {
	if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
		# shelcheck disable=SC1091
		if ! . "/usr/share/bash-completion/bash_completion"; then
			echo "alias_complete: Sourcing /usr/share/bash-completion/bash_completion failed" >&2
			return 2
		fi
	fi
	_longopt "$@"
}

_aLiAs_CoMpLeTe_::do::alias() {
	if (($# < 2)); then
		echo "alias_complete::do::alias: ERROR: need more then 2 arguments" >&2
		return 2
	fi

	local alias_name
	alias_name=$1
	shift
	local cmd
	cmd=$1
	local cmd_with_args
	cmd_with_args=("$@")

	if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
		# echo _aLiAs_CoMpLeTe_::do::alias sourcing /usr/share/bash-completion/bash_completion
		# shelcheck disable=SC1091
		if ! . "/usr/share/bash-completion/bash_completion"; then
			echo "alias_complete: Sourcing /usr/share/bash-completion/bash_completion failed" >&2
			return 2
		fi
	fi

	local tmp
	if ! tmp=$(complete -p "$cmd" 2>/dev/null); then
		# echo _aLiAs_CoMpLeTe_::do::alias sourcing /usr/share/bash-completion/completions/$cmd
		# shellcheck disable=SC1090
		if ! . "/usr/share/bash-completion/completions/$cmd"; then
			echo "alias_complete: Sourcing /usr/share/bash-completion/completions/$cmd failed" >&2
			return 2
		fi
		if ! tmp=$(complete -p "$cmd" 2>/dev/null); then
			echo "alias_complete: No completion found for $cmd" >&2
			return 2
		fi
	fi

	# echo "_aLiAs_CoMpLeTe_::do::alias complete -p $cmd -> $tmp"
	local complete_cmd IFS
	IFS=' '
	read -r -a complete_cmd <<<"$tmp"

	if [[ "${complete_cmd[-1]}" != "$cmd" ]]; then
		echo "alias_complete: Internal error: Something very wrong happened" >&2
		return 2
	fi
	unset 'complete_cmd[-1]'

	local i next_is_func complete_args complete_func
	next_is_func=false
	for i in "${complete_cmd[@]}"; do
		if [[ "$i" == "-F" ]]; then
			next_is_func=true;
			continue
		fi
		if "$next_is_func"; then
			complete_func="$i"
			continue
		fi
		complete_args+=("$i")
	done

	if [[ -z "${complete_func:-}" ]]; then
		echo "alias_complete: error: for it to work, aliased command has to be completed with a function" >&2
		return 1
	fi
	if ! declare -f "$complete_func" >/dev/null; then
		echo "alias_complete: internal error: $complete_func does not exists"  >&2
		return 2
	fi

	local cmd_with_args_star_len
	cmd_with_args_star_len="$(IFS=" "; echo "${cmd_with_args[*]}")"
	cmd_with_args_star_len="${#cmd_with_args_star_len}"

	eval '_aLiAs_CoMpLeTe_::'"$alias_name"'() {
		# echo >&2
		# echo "_aLiAs_CoMpLeTe_ \$#=\"$#\" \$1=\"$1\" \$2=\"$2\" \$3=\"$3\" CWORD=\"$COMP_CWORD\"" >&2
		# echo "_aLiAs_CoMpLeTe_ WORDS=\"$(IFS="|"; echo "${COMP_WORDS[*]}")\" LINE=\"$COMP_LINE\" POINT=\"$COMP_POINT\"" >&2

		local          cmd_with_args alias_name complete_func cmd_with_args_star_len
		'"$(declare -p cmd_with_args alias_name complete_func cmd_with_args_star_len)"'

		if ((COMP_CWORD == 1)); then
			set -- "${cmd_with_args[0]}" "$2" "${cmd_with_args[-1]}"
		else
			set -- "${cmd_with_args[0]}" "$2" "$3"
		fi
		((COMP_CWORD += ${#cmd_with_args[@]} - 1)) ||:
		COMP_WORDS=("${cmd_with_args[@]}" "${COMP_WORDS[@]:1}")
		COMP_LINE="$(IFS=" "; echo "${cmd_with_args[*]}")${COMP_LINE#"$alias_name"}"
		((COMP_POINT += ${cmd_with_args_star_len} - ${#alias_name})) ||:
		
		# echo "_aLiAs_CoMpLeTe_ \$#=\"$#\" \$1=\"$1\" \$2=\"$2\" \$3=\"$3\" CWORD=\"$COMP_CWORD\"" >&2
		# echo "_aLiAs_CoMpLeTe_ WORDS=\"$(IFS="|"; echo "${COMP_WORDS[*]}")\" LINE=\"$COMP_LINE\" POINT=\"$COMP_POINT\"" >&2

		"$complete_func" "$@"
	}'
	"${complete_args[@]}" -F "_aLiAs_CoMpLeTe_::$alias_name" "$alias_name"
}

# Main #########################

if "$_aLiAs_CoMpLeTe__longopt"; then
	if (($# > 1)); then
		_aLiAs_CoMpLeTe__fatal "The --longopt options uses only alias name."
	fi
	complete -F "_aLiAs_CoMpLeTe_::longopt" "$1"
elif "$_aLiAs_CoMpLeTe__shortopt"; then
	if (($# > 1)); then
		_aLiAs_CoMpLeTe__fatal "The --shortopt options uses only alias name"
	fi
	complete -F "_aLiAs_CoMpLeTe_::shortopt" "$1"
else
	_aLiAs_CoMpLeTe__alias_name="$1"
	if (($# < 2)); then
		_aLiAs_CoMpLeTe__fatal "Command argument exprected"
	fi
	if [[ -z "$2" ]]; then
		_aLiAs_CoMpLeTe__fatal "Command is empty"
	fi
	_aLiAs_CoMpLeTe__cmd="$2"
	shift 2
	_aLiAs_CoMpLeTe__args=("$@")

	# Do the normal completion

	if "$_aLiAs_CoMpLeTe__withalias"; then
		# shellcheck disable=SC2139
		alias "$_aLiAs_CoMpLeTe__alias_name=$(printf "%q " "$cmd" "$@")"
	fi

	eval '
	_aLiAs_CoMpLeTe_::setup::'"$_aLiAs_CoMpLeTe__alias_name"'() {
		local _aLiAs_CoMpLeTe__alias_name _aLiAs_CoMpLeTe__cmd _aLiAs_CoMpLeTe__args
		'"$(declare -p _aLiAs_CoMpLeTe__alias_name _aLiAs_CoMpLeTe__cmd _aLiAs_CoMpLeTe__args)"'
		_aLiAs_CoMpLeTe_::do::alias "$_aLiAs_CoMpLeTe__alias_name" "$_aLiAs_CoMpLeTe__cmd" "${_aLiAs_CoMpLeTe__args[@]}" &&
		_aLiAs_CoMpLeTe_::"$_aLiAs_CoMpLeTe__alias_name" "$@"
	}
	'
	complete -F "_aLiAs_CoMpLeTe_::setup::$_aLiAs_CoMpLeTe__alias_name" "$_aLiAs_CoMpLeTe__alias_name"
fi

_aLiAs_CoMpLeTe__clearenv

