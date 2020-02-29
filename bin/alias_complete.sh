#!/bin/bash
set -euo pipefail

if [[ "${ALIAS_COMPLETE_DEBUG:-false}" = "true" ]]; then
	set -x
fi

# Functions ##########################################################

usage() {
      cat <<'EOF'
Usage: 
	alias_complete.sh [options] name command [args...]
	eval "$(alias_complete.sh name command [args])"

Aliases autocompletion scripts of alias with the name "name"
to command "command [args...]".
Tries to handle all arguments and COMP_* vairables.

Options:
	-h --help        - Print this help and exit.
	-a --with-alias  - Also print alias='command args...'.
	--longopt        - Alias this command to _longopt autocompletion.
	--shortopt       - Alias this command to _shortopt autocompletion.
	-s --silent      - Silence the output. Don't show any output except success.

Usage examples:
	- alias l='ls -la'
	  eval "$(alias_complete.sh l ls)
	- alias pS='pacman -S --noconfirm'
	  eval "$(alias_complete.sh pS pacman -S --noconfirm)"
	- Or just:
	  eval "$(alias_complete.sh -a pS pacman -S --noconfirm)"

Written by Kamil Cukrowski
Licensed jointly under MIT License and Beerware License.
EOF
}

fatal() {
	declare -g silent
	if ! "$silent"; then
		echo "alias_complete.sh: ERROR:" "$@" >&2
	fi
	exit 2
}

# Parse arguments ###########################################################

shortopt=false
longopt=false
withalias=false
silent=false
while (($#)); do
	case "$1" in
	-h|--help) usage; exit 0; ;;
	-a|--with-alias) withalias=true; ;;
	--longopt) longopt=true; ;;
	--shortopt) shortopt=true; ;;
	-s|--silent) silent=true; ;;
	--) shift; break; ;;
	-*) fatal "Unknown option: $1"; ;;
	*) break; ;;
	esac
	shift
done

if (($# < 1)); then
	usage
	fatal "No alias name specified"
fi

alias_name="$1"
if [[ -z "$alias_name" ]]; then
	fatal "First argument is empty"
fi

if "$longopt" && "$shortopt"; then
	fatal "The --shortopt and --longopt cannot be used together. --shortopt includes --longopt"
fi
if ( "$longopt" || "$shortopt" ) && "$withalias"; then
	fatal "The --with-alias must be used without --shortopt not --longopt. To which command shoud we alias?"
fi

# handle longopt
if "$longopt"; then
	if (($# > 1)); then
		fatal "The --longopt options uses only alias name."
	fi
	cat <<'EOF'
_alias_complete::longopt() {
	if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
		. "/usr/share/bash-completion/bash_completion"
	fi
	_longopt "$@"
}
EOF
	cat <<EOF
complete -F _alias_complete_longopt "$alias_name"
EOF
	exit
fi

# handle shortopt
if "$shortopt"; then
	if (($# > 1)); then
		fatal "The --shortopt options uses only alias name"
	fi

	: <<'EOF'
_alias_complete::shortopt() {
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
            local argtype=$(LC_ALL=C $1 --help 2>&1 |
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

    COMPREPLY=( $(compgen -W "$(
         LC_ALL=C "$1" --help 2>&1 |
         command tr ' ' '\n' |
         command grep -x -- '-[-A-Za-z0-9]\+\(=.*\)\?' |
         command cut -d= -f2- |
         command sort -u
    )" -- "$cur") )
}
EOF
	cat <<EOF
$(declare -f _alias_complete::shortopt)
complete -F _alias_complete::shortopt "$alias_name"
EOF
	exit
fi

# parse rest of options

if (($# < 2)); then
	fatal "Command argument exprected"
fi
cmd="$2"
if [[ -z "$cmd" ]]; then
	fatal "Command is empty"
fi
shift 2
cmd_args=("$@")

if [[ "$cmd" =~ *[[:space:]]* ]]; then
	fatal "The script does not work with commands with spaces in it."
fi

# Do the normal completion

output=$(

if "$withalias"; then
	cmd_with_args_escaped=$(printf " %q" "$cmd" "${cmd_args[@]}" | cut -c2-)
	echo "alias $alias_name='$cmd_with_args_escaped'"
fi

_complete_alias::do::alias() {
	if (($# < 2)); then
		echo "complete_alias::do::alias: ERROR: need more then 2 arguments" >&2
		return 2
	fi

	local alias_name cmd cmd_args
	alias_name=$1
	cmd=$2
	shift 2
	cmd_args=("$@")

	local tmp
	if [[ -z "${BASH_COMPLETION_VERSINFO:-}" ]]; then
		# echo _complete_alias::do::alias sourcing /usr/share/bash-completion/bash_completion
		if ! . "/usr/share/bash-completion/bash_completion"; then
			echo "complete_alias: Sourcing /usr/share/bash-completion/bash_completion failed" >&2
			return 2
		fi
	fi
	if ! tmp=$(complete -p "$cmd" 2>/dev/null); then
		# echo _complete_alias::do::alias sourcing /usr/share/bash-completion/completions/$cmd
		if ! . "/usr/share/bash-completion/completions/$cmd"; then
			echo "complete_alias: Sourcing /usr/share/bash-completion/completions/$cmd failed" >&2
			return 2
		fi
		if ! tmp=$(complete -p "$cmd" 2>/dev/null); then
			echo "complete_alias: No completion found for $cmd" >&2
			return 2
		fi
	fi

	# echo "_complete_alias::do::alias complete -p $cmd -> $tmp"
	local complete_func complete_args cmd_with_args cmd_args_cnt cmd_with_args_escaped 
	local complete_args_escaped new_complete_func
	tmp=$(<<<"$tmp" tr ' ' '\n' | sed '$d')
	complete_func=$(<<<"$tmp" grep -A1 -- '-F' | tail -n1)
	if ! declare -f "$complete_func" >/dev/null; then
		echo "complete_alias: internal error: $complete_func does not exists"  >&2
		return 1
	fi
	complete_args=($(<<<"$tmp" grep -v -x -- '-F\|'"${complete_func}"))

	cmd_with_args=("$cmd" "${cmd_args[@]}")
	cmd_args_cnt=${#cmd_args[@]}
	cmd_with_args_escaped=$(printf " %q" "$cmd" "${cmd_args[@]}" | cut -c2-)

	eval "$(cat <<EOF2
	_complete_alias::$alias_name() {
		# echo "$new_complete_func: '\$#' '\$1' '\$2' '\$3' '\$COMP_CWORD' '\${COMP_WORDS[@]}' '\$COMP_LINE' '\$COMP_POINT'"
		if ((COMP_CWORD == 1)); then
			set -- "$cmd" "\$2" "${cmd_with_args[-1]}"
		else
			set -- "$cmd" "\$2" "\$3"
		fi
		((COMP_CWORD += $cmd_args_cnt)) ||:
		COMP_WORDS=($cmd_with_args_escaped \${COMP_WORDS[@]:1})
		COMP_LINE="$cmd_with_args_escaped\${COMP_LINE#"$alias_name"}"
		((COMP_POINT += ${#cmd_with_args_escaped} - ${#alias_name})) ||:
		# echo "$new_complete_func: '\$#' '\$1' '\$2' '\$3' '\$COMP_CWORD' '\${COMP_WORDS[@]}' '\$COMP_LINE' '\$COMP_POINT'"
	
		"$complete_func" "\$@"
	}
EOF2
	)"
	"${complete_args[@]}" -F "_complete_alias::$alias_name" "$alias_name"
}

cat <<EOF
$(declare -f _complete_alias::do::alias)
_complete_alias::setup::$alias_name() {
	local alias_name cmd cmd_args
	alias_name=$(printf "%q" "$alias_name")
	cmd=$(printf "%q" "$cmd")
	cmd_args=($( ((${#cmd_args[@]})) && printf "%q " "${cmd_args[@]}" || :))
EOF
cat <<'EOF'
	_complete_alias::do::alias "$alias_name" "$cmd" "${cmd_args[@]}" &&
	_complete_alias::$alias_name "$@"
}
EOF
cat <<EOF
complete -F '_complete_alias::setup::$alias_name' '$alias_name'
EOF

)

if ! bash >/dev/null <<EOF
$output
complete -p '$alias_name' || exit 1
declare -F _complete_alias::do::alias '_complete_alias::setup::$alias_name' || exit 1
EOF
then
	fatal "Internal error: Output from this script is invalid."
fi

cat <<<"$output"

