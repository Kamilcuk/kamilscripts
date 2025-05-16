#!/bin/bash

_ssh_remote_function_usage() {
   cat >&2 <<EOF
Usage: ssh_remote_function [OPTIONS] USER@HOST FUNCTION [ARGS...]
Executes ssh USER@HOST and executes FUNCTION on the remote side with arguments.
Options:
  -h              Print this help and exit.
  -f FUNCTION     Send this function to remote side.
  -v VARIABLE     Send this variable to remote side.
  -o SH_OPT       Add this option to Bash shell.
  -s SSH_OPT      Add this optino to ssh.
  -i INIT_SCRIPT  Additional shell script to execute on initialization.
                  The script is prefixed and suffixed with a semicolon.
Example:
   work() { echo "Some code to execute"; echo "variable=$variable"; echo "Argument=$1"; }
   variable=123
   ssh_remove_function -v variable -s -t -o -x -i 'set -xeuo pipefail' work argument
Written by Kamil Cukrowski 2025
EOF
}

ssh_remote_function() {
   local OPTARG OPTIND OPTERR s_o s_shopts=() s_init="" s_sshopts=()
   while getopts hf:v:o:s:i: s_o; do
      case $s_o in
      h) _ssh_remote_function_usage; return 0; ;;
      f) if ! s_init+="$(declare -f "$OPTARG");"; then echo "${FUNCNAME[0]}: ERROR: could not serialize $OPTARG function" >&2; return 2; fi ;;
      v) if ! s_init+="$(declare -p "$OPTARG");"; then echo "${FUNCNAME[0]}: ERROR: could not serialize $OPTARG variable" >&2; return 2; fi ;;
      o) s_shopts+=("$OPTARG") ;;
      s) s_sshopts+=("$OPTARG") ;;
      i) s_init+="$OPTARG;" ;;
      *) _ssh_remote_function_usage "invalid argument: $s_o" >&2; return 2 ;;
      esac
   done
   shift $((OPTIND-1))
   if (($# == 0)); then echo "${FUNCNAME[0]}: ERROR: missing USER@HOST argument" >&2; return 2; fi
   if (($# == 1)); then echo "${FUNCNAME[0]}: ERROR: missing FUNCTION argument" >&2; return 2; fi
   if ! s_init+="$(declare -f "$2")"; then echo "${FUNCNAME[0]}: ERROR: could not serialize $2 function" >&2; return 2; fi
   ssh "${s_sshopts[@]}" "$1" "$(printf "%q " bash "${s_shopts[@]}" -c "$s_init;$2 \"\$@\"" "$2" "${@:3}")"
}

