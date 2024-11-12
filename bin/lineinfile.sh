#!/bin/bash
# shellcheck disable=2016
set -euo pipefail

[ "${DEBUG:-false}" = true ] && { set -x; LOGLVL=100; }

# functions #################

usage() {
	cat <<EOF
Usage: lineinfile.sh [options] file

This module ensures a particular line is in a file, or replace an existing line.
This is primarily useful when you want to change a single line in a file only.
The script loosly based on ansible lineinfile module.
The script has no backreferences, because you can do that yourself with sed '/line/s/li\(.*\)/\1/'.

Options:
	-d, --delete            - Delete the line
	-l, --line=line         - Specify the exact line
	-r, --regex=regex       - Line specified with regex, matched with grep
	-c, --create            - Create the file if it does not exists
	-V, --validate=command  - Run this command after substitution
	-t, --unittest          - Run internal unittests
	-h, --help              - Run this help and exit
	-s, --silent            - Print less output

Examples:
	lineinfile.sh -l "source /my/ultimate/config.sh" /etc/bash.bashrc
	lineinfile.sh -d -r "^#" /etc/bash.bashrc

Written by Kamil Cukrowski 2019
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3..
EOF
}

assert() {
	if eval "$1"; then
		return
	else
		local expr ret=$?
		expr="$1"
		shift
		echo "Expression '$expr' failed with $ret from $(caller 0)" >&2
		if (($#)); then
			echo "$@" >&2
		fi
		exit 1
	fi
}

log() {
	if [ "${LOGLVL:-0}" -lt "$1" ]; then
		return
	fi
	if [ "$1" -gt 1 ]; then
		printf "%.0s " $(seq "$1")
	fi
	shift
	echo "$@" 
}

unittest() {
	tmp=$(mktemp)
	tmp2=$(mktemp)
	trap 'rm "$tmp" "$tmp2"' EXIT
	
	cat <<EOF >"$tmp"
line1
notline
line3
EOF

	assert '[ $(wc -l <"$tmp") -eq 3 ]' 1
	$0 -l line4 "$tmp"
	assert '[ $(wc -l <"$tmp") -eq 4 ]' 2
	assert 'grep -q line4 "$tmp"'
	$0 -d -l line4 "$tmp"
	assert '[ $(wc -l <"$tmp") -eq 3 ]' "$(cat "$tmp")"
	assert '! grep -q line4 "$tmp"'
	$0 -d -r '^line' "$tmp"
	assert '! grep -q line1 "$tmp"'
	assert '! grep -q line3 "$tmp"'	
	assert '[ $(wc -l <"$tmp") -eq 1 ]' 2
	assert 'grep -q notline "$tmp"'
	
		
	cat <<EOF >"$tmp"
line1
notline
line3
EOF
	$0 -r '^line' -l line4 "$tmp"
	assert '[ $(wc -l <"$tmp") -eq 3 ]' "$(cat "$tmp")"
	assert 'grep -q line1 "$tmp"'
	
	rm "$tmp"
	assert '! $0 -l line "$tmp"'
	$0 -c -l line "$tmp"
	assert '[ $(wc -l <"$tmp") -eq 1 ]' "$(cat "$tmp")"
	assert 'grep -q line "$tmp"'
	
	echo line > "$tmp2"
	assert '$0 -c -l line -V "cmp %s $tmp2" "$tmp"'
	
	echo line2 > "$tmp2"
	assert '! $0 -c -l line -V "cmp %s $tmp2" "$tmp"' 
	
	echo "Unittest successfull"
}

# main ###################

(($# == 0)) && { usage; exit 1; }

ARGS=$(getopt -n lineinfile -o dl:r:cV:ths -l delete,line:,regex:,create:,validate:,unittest,help,silent -- "$@")
eval set -- "$ARGS"

delete=false
line=
regex=
create=false
validate=
LOGLVL=${LOGLVL:-1}
while (($#)); do
	case "$1" in
	-d|--delete) delete=true; ;;
	-l|--line) line=$2; shift; ;;
	-r|--regex) regex=$2; shift; ;;
	-c|--create) create=true; ;;
	-V|--validate) validate=$2; shift; ;;
	-t|--unittest) unittest; exit; ;;
	-h|--help) usage; exit; ;;
	-s|--silent) LOGLVL=0; ;;
	--) shift; break; ;;
	*) assert 'false' 'Internal error' "$@"; ;;
	esac
	shift
done

(($# < 1)) && assert false 'Not enough arguments'
(($# > 1)) && assert false 'Too many arguments'

file=$1

# work

if ! "$delete"; then
	assert '[ -n "$line" ]' '--line parameter must be specified when not deleting'
	if ! "$create"; then
		assert '[ -e "$file" ]' "File $file does not exists"
		assert '[ -w "$file" ]' "No write permission to $file are granted"
	else
		if [ ! -f "$file" ]; then
			printf "%s\n" "$line" > "$file"
			exit
		fi
	fi
	
	if [ -z "$regex" ]; then
		if match=$(
			grep -n -F -x "$line" "$file" |
			tail -n1 | cut -f1 -d:
		); then
			log 1 "Line=$line found on lineno=$match in $file. No action needed"
		else
			log 1 "Appending line=$line to file=$file"
			printf "%s\n" "$line" >> "$file"
		fi
	else
		if matchcontent=$(
			grep -n "$regex" "$file" |
			tail -n1
		); then
			IFS=: read -r match content <<<"$matchcontent"
			log 1 "Replacing lineno=$match with content=$content file=$file with line=$line"
			sed -i -e "$match"' c'"$line" "$file"
		else
			log 1 "Appending line=$line to file=$file"
			printf "%s\n" "$line" >> "$file"
		fi
	fi
	
else
	assert '[ -w "$file" ]' "No write permission to $file are granted"
	assert '[ -z "$line" -a -n "$regex" ] || [ -n "$line" -a -z "$regex" ]' \
		"Specify regex or line to delete, not both"
	
	tmp=$(mktemp)
	trap 'rm -f "$tmp"' EXIT
	
	if [ -z "$regex" ]; then
		log 1 "Removing exact line=$line from file=$file"
		grep -F -x -v "$line" "$file" > "$tmp"
	else
		log 1 "Removing regex=$regex from file=$file"
		grep -v "$regex" "$file" > "$tmp"
	fi
	cp "$tmp" "$file"
	rm "$tmp"
	trap '' EXIT 
fi

if [ -n "$validate" ]; then
	# shellcheck disable=2059
	validate=$(printf -- "$validate" "$file")
	log 1 "Executing validate script '$validate'"
	if $validate; then
		log 3 "Validation successfull"
	else
		exit $?
	fi
fi

