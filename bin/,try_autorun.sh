#!/bin/bash
set -euo pipefail

name=$(basename "$0")

run() {
	echo "+" "$@" >&2
	if ! "$dry_run"; then
		"$@"
	fi
}

fatal() {
	echo "$name: error:" "$@" >&2
	exit 1
}

be_nice() {
	if (($(nice) < 10)); then
		ionice=()
		if { ionice -V 2>&1 | grep -q util-linux; } 2>/dev/null; then
			ionice=(ionice --)
		fi
		exec nice -n 20 -- "${ionice[@]}" "$0" "$@"
	fi
}

usage() {
	cat <<EOF
Usage: $name [options] <file>

Tries to compile and automatically run the file or the project.

Options:
   -e filetype   Pass filetype as vim filetype.
   -S            Synchronize stderr with stdout and be line buffered.
   -p            Try to detect project files: makefile, cmake, etc..
   -n            Dry run.
   -h            Print this help and exit.

Written by Kamil Cukrowski
Licensed jointly under Beerware Licsense and MIT License
EOF
}

parse_arguments() {
	declare -g file use_project dry_run sync_output
	use_project=false
	dry_run=false
	file=""
	sync_output=false

	local o
	while getopts ":e:pSnh" o; do
		case "$o" in
		e) ;;
		p) use_project=true; ;;
		S) sync_output=true; ;;
		n) dry_run=true; ;;
		h) usage; exit 0; ;;
		*) fatal "Invalid argument: -$OPTARG"; ;;
		esac
	done
	shift "$((OPTIND-1))"
	if (($# != 1)); then
		fatal "Invalid count of arguments"
	fi		
	file=$1
}
	
# main #########################################

be_nice "$@"

parse_arguments "$@"

cflags=(
	-Wall -Wextra
	-ggdb3
	-fsanitize=address -fsanitize=undefined -fsanitize=pointer-compare -fsanitize=pointer-subtract -fsanitize-address-use-after-scope
)

if "$use_project"; then
	if [[ -e 'Makefile' ]]; then
		run make
		exit
	elif [[ -e 'CMakeLists.txt' ]] &&
			grep -q 'cmake_minimum_required\s*\(\s*VERSION.*\)' 'CMakeLists.txt'; then
		args=()
		if hash ninja 2>/dev/null; then args+=(-G Ninja); fi

		run cmake -S. -B_build "${args[@]}" \
			-DCMAKE_VERBOSE_MAKEFILE=yes \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
			-DCMAKE_C_FLAGS="${cflags[*]}" \
			-DCMAKE_CXX_FLAGS="${cflags[*]}" \
			-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$PWD"/_build/bin \
			-DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			&&
		run cmake --build _build &&
		( cd _build && run ctest -V )
		exit
	fi
fi

ext=${file,,}
ext=${file##*.}
case "$ext" in
c)
	: "${ccompiler:=gcc}"
	;& # fallthrough
cpp|cxx|cc|c++)
	: "${ccompiler:=g++}"
	if [[ -z "$ccompiler" ]] || ! hash "$ccompiler" 2>/dev/null; then
		fatal "Compiler could not be found: $ccompiler"
	fi
	tmp=$(mktemp --suffix='.out')
	trap 'rm "$tmp"' EXIT
	{
		if "$sync_output"; then
			exec 1>&2
		fi
		echo "+" "$ccompiler" "${cflags[@]}" "$file" >&2
		"$ccompiler" "${cflags[@]}" -o "$tmp" "$file"
		"$tmp"
	}
	# tmp removed on EXIT
	;;
py)
	run python "$file"
	;;
sh|bash|bashrc)
	run bash "$file"
	;;
*) 
	fatal "Don't know how to build $file"
esac


