#!/bin/bash
# usage below

#if hash cdb 2>/dev/null >/dev/null; then
#	return
#fi

cdb() {
	local cdb_dir
	cdb_dir=${CDB_DIR:-~.cache/cdb}
	case "${1:-}" in
	-u|--unmark|-g|--get)
		if (($# != 2)); then "cdb: Wrong number of arguments: $#" >&2; return 2; fi
		local names i
		names=()
		if [[ "$2" != '.' && "$2" != '..' && -L "$cdb_dir/$2" ]]; then
			names+=("$cdb_dir/$2")
		elif [[ -d "$2" ]]; then
			for i in "$cdb_dir"/*; do
				if [[ ! -L "$i" ]]; then continue; fi
				if [[ "$i" -ef "$2" ]]; then
					names+=("$i")
				fi
			done
		fi
		if ((!${#names})); then echo "cdb: Mark does not exists: $2" >&2; return 1; fi
		for i in "${names[@]}"; do
			if [[ ! -e "$i" && -L "$i" ]]; then echo "cdb: Broken link: $i"; continue; fi
			if [[ ! -L "$i" ]]; then echo "cdb: Internal error 2 $i" >&2; return 2; fi
			if [[ ! "$i" -ef "$cdb_dir/$(basename "$i")" ]]; then echo "cdb: Internal error 3 $i" >&2; return 2; fi
		done
		;;
	esac

	case "${1:-}" in
	-m|--mark)
		local name dest
		name=""
		case "$#" in
		2) dest="$2"; ;;
		3) name="$2"; dest="$3"; ;;
		*) echo "cdb: Wrong number of arguments" >&2; return 2; ;;
		esac
		if [[ ! -e "$dest" ]]; then echo "cdb: Path does not exists: $dest" >&2; return 2; fi
		if [[ ! -d "$dest" ]]; then echo "cdb: Is not a directory: $dest" >&2; return 2; fi
		if [[ -z "$name" ]]; then
			if ! name=$(readlink -f -- "$dest"); then echo "cdb: Error readlink -f $name" >&2; return 2; fi
			if ! name=$(basename -- "$name"); then echo "cdb: Error basename $name" >&2; return 2; fi
		fi
		if [[ -z "$name" ]]; then echo "cdb: Error: name is empty: $name" >&2; return 2; fi
		if [[ "$name" = "." || "$name" = ".." ]]; then echo "cdb: Error: invalid name: $name" >&2; return 2; fi
		if [[ -e "$cdb_dir/$name" ]]; then echo "cdb: Mark already exists: $name -> $(readlink -f "$cdb_dir/$name")" >&2; return 1; fi
		if ! (
				dest=$(cd "$dest" && echo "$PWD") &&
				mkdir -p "$cdb_dir" &&
				cd "$cdb_dir" &&
				ln -v -s "$dest" "$name"
		); then
			echo "cdb: Failed to create the link" >&2
			return 1
		fi
		;;
	-u|--unmark)
		# names is set above
		rm "${names[@]}"
		for i in "${names[@]}"; do
			echo "removed ${i##*/} -> $(readlink -f "$i")"
		done
		;;
	-g|--get)
		# names is set above
		pushd "$cdb_dir" >/dev/null || return 1
		find "${names[@]}" -type l -printf '%f -> %l\n' | sort
		popd >/dev/null || return 1
		;;
	-l|--list)
		if (($# != 1)); then echo "cdb: Wrong number of arguments" >&2; return 2; fi
		if [[ ! -e "$cdb_dir" ]]; then return; fi
		find "$cdb_dir" -type l -printf '%f -> %l\n' | sort
		;;
	*)
		if (($# != 1)) || [[ "$1" = -h ]] || [[ "$1" == "--help" ]]; then 
			cat <<EOF
Usage:
	cdb <name>
	cdb -m|--mark <directory>
	cdb -m|--mark <name> <directory>
	cdb -u|--unmark <directory>
	cdb -u|--unmark <name>
	cdb -l|--list
	cdb -g|--get <name>
	cdb -g|--get <directory>
	cdb -h|--help

cdb - Change Directory Bookmarked

Keep a list of manually bookmarked directories for fast
navigation between them in terminal.

Options:
  -m --mark <directory>
  -m --mark <name> <directory>
  		Bookmark a directory
        If one argument is given, the basename of the directory
        is used as the mark name. Otherwise the first argument
        if the name of the bookmark.
  -u --unmark <name>
  -u --unmark <directory>
     	Remove the directory from bookmarking.
     	The argument can be the name of the bookmark, in which
     	case the bookmark is removed.
     	The argument can be a directory, in which case all bookmarks
     	to this directory are removed.
  -l --list
  		List all bookmarks
  -g --get <name>
  -g --get <directory>
  		Print the destination of the directory
  -h --help
  		Print this help and exit.
  <name>
  		Navigate to bookmark named <name>.

Bookmarks are created in the directory referenced by
environment variable cdb_dir. Currently:
    cdb_dir=$cdb_dir

Written by Kamil Cukrowski
EOF
			return
		fi
		if (($# != 1)); then echo "cdb: Wrong number of arguments" >&2; return 2; fi
		if [[ ! -e "$cdb_dir/$1" ]]; then echo "cdb: No such mark: $1" 2>&1; return 1; fi
		if ! cd -P "$cdb_dir/$1"; then echo "cdb: Error changing directory: $1" 2>&1; return 2; fi
		;;
	esac
}

# shellcheck disable=2207
_cdb_completion() {
	local cdb_dir
	cdb_dir=${CDB_DIR:-~/.cache/cdb}
	# if ((COMP_CWORD > 2)); then return; fi
	if ((COMP_CWORD == 1)); then
  		case "${COMP_WORDS[COMP_CWORD]}" in
  		-*)
			COMPREPLY=($(compgen -W '-m --mark -u --unmark -l --list -h --help' -- "${COMP_WORDS[COMP_CWORD]}"))
			;;
		*)
			if [[ ! -e "$cdb_dir" ]]; then return; fi
			pushd "$cdb_dir" >/dev/null || return
			COMPREPLY=($(compgen -o dirnames -d -- "${COMP_WORDS[COMP_CWORD]}"))
			popd >/dev/null || return 1
			if ((!${#COMPREPLY})); then
				COMPREPLY=($(compgen -W '-m --mark -u --unmark -l --list -h --help' -- "${COMP_WORDS[COMP_CWORD]}"))
			fi
			;;
		esac
	elif ((COMP_CWORD == 2 || COMP_CWORD == 3)); then
		case "${COMP_WORDS[1]}" in
		-m|--mark)
			COMPREPLY=($(compgen -o dirnames -d -- "${COMP_WORDS[COMP_CWORD]}"))
			;;
		-u|--unmark|-g|--get)
			if [[ ! -e "$cdb_dir" ]]; then return; fi
			pushd "$cdb_dir" >/dev/null
			COMPREPLY=($(compgen -o dirnames -- "${COMP_WORDS[COMP_CWORD]}"))
			popd >/dev/null
			;;
		esac
	fi
}
complete -o filenames -F _cdb_completion cdb

