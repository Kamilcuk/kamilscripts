#!/bin/bash
set -euo pipefail

name=$(basename "$1")

usage() {
	cat <<EOF
Usage: $name <filetype> <file>

Tries to compile and automatically run the file or the project.

Written by Kamil Cukrowski
EOF
}

if (($# != 2)); then
	usage
	exit
fi

if hash nice 2>/dev/null && (($(nice) > 10)); then
	ionice=()
	if ionice -V 2>&1 | grep -q util-linux; then
		ionice=(ionice)
	fi
	exec nice -n 20 -- "${ionice[@]}" "$0" "$@"
fi

filetype=$1
file=$2
cflags="-Wall -Wextra -ggdb3 -fsanitize=address -fsanitize=undefined -fsanitize=pointer-compare -fsanitize=pointer-subtract -fsanitize-address-use-after-scope"

if [[ -e "Makefile" ]]; then
	( set -x && make )
elif [[ -e "CMakeLists.txt" ]] && grep -q 'cmake_minimum_required' 'CMakeLists.txt'; then
	args=()
	if hash ninja 2>/dev/null; then
		args+=(-G Ninja)
	fi
	( set -x
	cmake -S. -B_build "${args[@]}" \
		-DCMAKE_VERBOSE_MAKEFILE=yes \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
		-DCMAKE_C_FLAGS="$flags" \
		-DCMAKE_CXX_FLAGS="$flags" \
		-DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$PWD"/_build/bin &&
	cmake --build _build &&
	( cd _build && ctest -V )
	)
elif ccompiler=$(
		case "$filetype" in
			c) echo ',ccrun'; ;;
			cpp) echo ',c++run'; ;;
		esac
	) && [[ -n "$ccompiler" ]]; then
	( set -x
	"$compiler" "$file" "$flags"
	)
else
	echo "$name: Don't know how to build the project" >&2
	exit 1
fi


