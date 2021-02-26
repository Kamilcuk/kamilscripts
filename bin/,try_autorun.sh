#!/bin/bash
set -euo pipefail

name=$(basename "$0")

run() {
	printf "+ %s\n" "$*" >&2
	if ! "$g_dryrun"; then
		"$@"
	fi
}

runeval() {
	printf "+ %s\n" "$*" >&2
	if ! "$g_dryrun"; then
		eval "$1"
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
	declare -g file g_use_project g_dryrun g_sync_output
	g_use_project=false
	g_dryrun=false

	local o
	while getopts ":e:pSnh" o; do
		case "$o" in
		e) ;;
		p) g_use_project=true; ;;
		S) exec 2>&1; ;;
		n) g_dryrun=true; ;;
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

gcc_try_gcc_compile() (
	local tmps tmpo
	tmps=$(mktemp --tmpdir tmp.try_autorun.XXXXXXXXXX.c)
	tmpo=$(mktemp --tmpdir tmp.try_autorun.XXXXXXXXXX.out)
	trap 'rm "$tmps" "$tmpo"' EXIT
	echo 'int main(){}' > "$tmps"
	LC_ALL=C gcc "$@" "$tmps" -o "$tmpo" </dev/null
)

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

list_functions_prefixed() {
	declare -F | sed "/^declare -f $1/!d; s///"
}

,project_detect_make() {
	[[ -e 'Makefile' ]]
}

,project_run_make() {
	cflags_detect
	export CFLAGS="${cflags[*]}"
	export CXXFLAGS="${cflags[*]}"
	run make "$@"
}

,project_detect_cmake() {
	[[ -e 'CMakeLists.txt' ]] &&
	grep -q 'cmake_minimum_required\s*(\s*VERSION.*)' 'CMakeLists.txt'
}

,project_run_cmake() {
	local cdir tmp
	# Find CMakeCache.txt
	if
		tmp=$(timeout 1 find . -mindepth 1 -maxdepth 3 -type f -readable -name 'CMakeCache.txt' -print -quit) &&
		[[ -r "$tmp" ]]
	then
		cdir=${tmp%/*}
	else
		cdir=_build
		local args
		args=()
		if hash ninja 2>/dev/null; then args+=(-GNinja); fi
		cflags_detect
		run cmake -S. -B"$cdir" \
			-DCMAKE_VERBOSE_MAKEFILE=yes \
			-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
			-DCMAKE_C_FLAGS="${cflags[*]}" \
			-DCMAKE_CXX_FLAGS="${cflags[*]}" \
			-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$PWD"/_build/bin \
			-DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$PWD"/_build/lib \
			"${args[@]}"
	fi &&
	run cmake --build "$cdir" &&
	if [[ -e "$cdir"/CTestTestfile.cmake ]]; then
		( runeval "cd $(printf "%q" "$cdir") && ctest" )
	fi
}

# main #########################################

be_nice "$@"

parse_arguments "$@"
shift "$((OPTIND-1))"
if (($# != 1)); then usage; fatal "Invalid count of arguments: $#"; fi
file=$1
shift


if "$g_use_project"; then
	for i in $(list_functions_prefixed ,project_detect_); do
		if ,project_detect_"$i"; then
			,project_run_"$i" "$file"
			exit
		fi
	done
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


