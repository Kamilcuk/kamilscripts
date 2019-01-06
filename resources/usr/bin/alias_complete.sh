#!/bin/bash
set -euo pipefail

usage() {
      cat <<EOF
Usage: 
      eval $(completion_alias.sh name command ...)

Add autocompletions command for alias named "name" 
as-if it is a command command.

Usage examples:
      - alias l='ls -la'
        eval "$(completion_alias.sh l ls)
      - alias pS='pacman -S --noconfirm'
        eval "$(completion_alias.sh pS pacman -S)"

Written by Kamil Cukrowski
Licensed jointly under MIT License and Beerware License.
EOF
}

if (($# < 2)); then 
      usage
      exit 1
fi

alias_name="$1"
cmd="$2"
shift 2
cmd_args=("$@")
cmd_args_cnt=$#

if [[ "$cmd" = *[[:space:]]* ]]; then
      echo "ERROR: currently the script does not work with commands with spaces in it"
      exit 1
fi

. "/usr/share/bash-completion/completions/${cmd}"

complete_cmd_output=$(
      complete -p "$cmd" |
      tr ' ' '\n'
)

complete_func=$(
      <<<"$complete_cmd_output" \
      grep -A1 -- '-F' |
      tail -n1
)

complete_args=($(
      <<<"$complete_cmd_output" \
      head -n-1 |
      grep -v -- '-F\|'"${complete_func}" |
      tr '\n' ' '
))

cmd_with_args_escaped=$(/bin/printf "%q " "$cmd" "${cmd_args[@]}")
new_complete_func="_complete_alias_${alias_name}_to_${cmd}"
new_complete_func_body="${new_complete_func}() {
      ((COMP_CWORD += $cmd_args_cnt)) ;
      COMP_WORDS=($cmd_with_args_escaped\${COMP_WORDS[@]:1}) ;
      if ! declare -F $complete_func >/dev/null; then
            . /usr/share/bash-completion/completions/$cmd ;
      fi ;
      $complete_func ;
}"

echo "$new_complete_func_body && "
echo "${complete_args[@]}" -F "$new_complete_func" "$alias_name ;"


exit
