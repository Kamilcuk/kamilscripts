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
Usage: $name [options] <file> [tool_specific_arguments...]

Tries to compile and automatically run the file or the project.
Detects filetype using the extension of the file.
Chooses from gcc, g++, python, bash.
In project mode chooses from: make, cmake.

Options:
   -e filetype   Pass filetype as vim filetype.
   -S            Synchronize stderr with stdout and be line buffered.
   -p            Try to detect project files before detecting filetype.
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
}

gcc_version() {
	if ! gcc --version | grep '^gcc' | sed 's/^.* \([0-9]\+\.[0-9]\+\).*/\1/'; then
		fatal "Getting gcc version failed"
	fi
}

gcc_try_gcc_compile() {
	tmpf=$(mktemp --tmpdir tmp.try_autorun.XXXXXXXXXX.c)
	trap 'rm "$tmpf"' EXIT
	echo 'int main() { return 0; }' > "$tmpf"
	LC_ALL=C gcc "${cflags[@]}" "${sanitize[@]}" "$tmpf" </dev/null
}

awkeval() {
	if (($# != 1)); then fatal "internal error: awkeval takes one argument"; fi
	awk 'BEGIN{exit(!('"$1"'))}' <&-
}

awkeval_verbose() {
	if awkeval "$1"; then echo "$1 is true"; else echo "$1 is false"; return 1; fi
}

cflags_detect() {
	local base
	base=(
		-Wall
		-Wextra
		-ggdb3
	)
	# global cflags
	cflags=("${base[@]}")

	local ver
	if ! ver=$(gcc_version); then
		fatal "Could not get gcc version"
	fi

	local sanitize
	if awkeval "$ver >= 4.8"; then
		sanitize+=(-fsanitize=address)
	fi
	if awkeval "$ver >= 5"; then
		sanitize+=(-fsanitize=undefined)
	fi
	if awkeval "$ver >= 8"; then
		sanitize+=(-fsanitize=pointer-compare -fsanitize=pointer-subtract)
	fi
	local tmp
	if ((${#sanitize[@]} != 0)) && tmp=$(gcc_try_gcc_compile "${cflags[@]}" "${sanitize[@]}" 2>&1); then
		cflags+=("${sanitize[@]}")
	fi
}

# main #########################################

be_nice "$@"

parse_arguments "$@"
shift "$((OPTIND-1))"
if (($# != 1)); then usage; fatal "Invalid count of arguments"; fi
file=$1
shift

if "$use_project"; then
	if [[ -e 'Makefile' ]]; then
		cflags_detect
		export CFLAGS="${cflags[*]}"
		export CXXFLAGS="${cflags[*]}"
		run make "$@"
		exit
	elif [[ -e 'CMakeLists.txt' ]] &&
			grep -q 'cmake_minimum_required\s*(\s*VERSION.*)' 'CMakeLists.txt'; then
		args=()
		if hash ninja 2>/dev/null; then args+=(-G Ninja); fi
		cflags_detect

		if [[ -e "_build" && ! -e "_build/CMakeCache.txt" ]]; then
			fatal "cmake _build directory exists and is not cmake build dir. Bailing out"
		fi
		run cmake -S. -B_build "${args[@]}" \
			-DCMAKE_VERBOSE_MAKEFILE=yes \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
			-DCMAKE_C_FLAGS="${cflags[*]}" \
			-DCMAKE_CXX_FLAGS="${cflags[*]}" \
			-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$PWD"/_build/bin \
			-DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			"$@" \
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
	cflags_detect
	tmp=$(mktemp --suffix='.out')
	trap 'rm "$tmp"' EXIT
	{
		if "$sync_output"; then
			exec 1>&2
		fi
		echo "+" "$ccompiler" "${cflags[@]}" "$file" >&2
		"$ccompiler" "${cflags[@]}" "$@" -o "$tmp" "$file"
		"$tmp"
	}
	# tmp removed on EXIT
	;;
py)
	run python "$@" "$file"
	;;
sh|bash|bashrc)
	run bash "$@" "$file"
	;;
*) 
	fatal "Don't know how to build $file"
esac


