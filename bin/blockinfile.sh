#!/bin/bash
set -euo pipefail

[ "${DEBUG:-false}" = true ] && { set -x; LOGLVL=100; }

# functions #################

usage() {
	cat <<'EOF'
Usage: blockinfile.sh [options] file

This module will insert/update/remove a block of multi-line text surrounded by customizable marker lines.
The script is loosly based on ansible blockinfile module.

Options:
	-b, --block=string      - The text to insert inside the markers    
	-m, --marker=string     - The marker line template
	                          %s will be replaced by marker_begin or marker_end
	                          Default: '# %s blockinfile.sh MANAGED BLOCK'                        
	-B, --marker_begin=string 
	                        - The begin marger, default BEGIN
	-E, --marker_end=string - The end marger, default END  
	-d, --delete            - Delete the block
	-c, --create            - Create new file if it does not exists
	-V, --validate=command  - run this command after substitution
	-t, --unittest          - run internal unittests
	-h, --help              - run this help and exit
	-s, --silent            - less output
	
Examples:
	blockinfile.sh -c -b 'source /my/utilmate/config.sh' /etc/bash.bashrc
	blockinfile.sh -m "# %s customscript MANAGED BLOCK" -b "include $dir/etc/pacman.conf" /etc/pacman.conf

Written by Kamil Cukrowski 2019
Licensed jointly under MIT License and Beerware License.
EOF
}

assert() {
	if eval "$1"; then
		return
	else
		local expr ret=$?
		expr="$1"
		shift
		echo "Expression '$expr' failed with $ret in $(caller 0)" >&2
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
		printf "%.0s " $(seq $1)
	fi
	shift
	echo "$@" 
}

unittest() {
	tmp=$(mktemp)
	tmp2=$(mktemp)
	trap 'rm "$tmp" "$tmp2"' EXIT
	
	msg() {
		echo
		tail -n+1 "$tmp" "$tmp2"
	}
	
	assert '! $0 -m "blabla" "$tmp"' "$(msg)"
	assert '! $0 fnmda nfda' "$(msg)"
	
	$0 -b "contents" "$tmp"
	cat <<EOF >"$tmp2"
# BEGIN blockinfile.sh MANAGED BLOCK
contents
# END blockinfile.sh MANAGED BLOCK
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	$0 -b "contents"$'\n'"over"$'\n'"multiple lines" "$tmp"
	cat <<EOF >"$tmp2"
# BEGIN blockinfile.sh MANAGED BLOCK
contents
over
multiple lines
# END blockinfile.sh MANAGED BLOCK
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	cat <<EOF >"$tmp"
leading strings
more leading strings
# BEGIN blockinfile.sh MANAGED BLOCK
blabla
bfdkjsbfda
njfdnsaf
unrelated string to be removed
# END blockinfile.sh MANAGED BLOCK
some trailing strings
more trailing strings
EOF
	$0 -b "different"$'\n'"contents" "$tmp"
	cat <<EOF >"$tmp2"
leading strings
more leading strings
# BEGIN blockinfile.sh MANAGED BLOCK
different
contents
# END blockinfile.sh MANAGED BLOCK
some trailing strings
more trailing strings
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	$0 -m "# my marker %s" -B "begin" -E "end" -b " " "$tmp"
	cat <<EOF >"$tmp2"
leading strings
more leading strings
# BEGIN blockinfile.sh MANAGED BLOCK
different
contents
# END blockinfile.sh MANAGED BLOCK
some trailing strings
more trailing strings
# my marker begin
 
# my marker end
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	echo "trailing line" >>"$tmp"
	$0 -m "# my marker %s" -B "begin" -E "end" -b "some content"$'\n'"surely with a newline" "$tmp"
	cat <<EOF >"$tmp2"
leading strings
more leading strings
# BEGIN blockinfile.sh MANAGED BLOCK
different
contents
# END blockinfile.sh MANAGED BLOCK
some trailing strings
more trailing strings
# my marker begin
some content
surely with a newline
# my marker end
trailing line
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	$0 -d "$tmp"
	cat <<EOF >"$tmp2"
leading strings
more leading strings
some trailing strings
more trailing strings
# my marker begin
some content
surely with a newline
# my marker end
trailing line
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	$0 -m "# my marker %s" -B "begin" -E "end" -d "$tmp"
	cat <<EOF >"$tmp2"
leading strings
more leading strings
some trailing strings
more trailing strings
trailing line
EOF
	assert 'cmp "$tmp" "$tmp2"' "$(msg)"
	
	echo "Unittest successfull"
}

# main ###################

(($# == 0)) && { usage; exit 1; }

ARGS=$(getopt -n lineinfile \
	-o b:m:B:E:dcV:ths \
	-l block:,marker:,marker_begin:,marker_end:,delete,create,validate:,unittest,help,silent \
	-- "$@")
eval set -- "$ARGS"

delete=false
block=''
marker='# %s blockinfile.sh MANAGED BLOCK'
marker_begin='BEGIN'
marker_end='END'
create=false
validate=
LOGLVL=${LOGLVL:-1}

while (($#)); do
	case "$1" in
	-b|--block) block=$2; shift; ;;
	-m|--marker) marker=$2; shift; ;;
	-B|--marker_begin) marker_begin=$2; shift; ;;
	-E|--marker_end) marker_end=$2; shift; ;;
	-d|--delete) delete=true; ;;
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

assert 'grep -q "%s" <<<"$marker"' 'marker must have %s'
assert '[ "$marker_begin" != "$marker_end" ]' "marker_begin must be different then marker end"
if ! "$delete"; then
	assert '[ -n "$block" ]' "block must be specified"
fi

begin=$(printf -- "$marker" "$marker_begin")
end=$(printf -- "$marker" "$marker_end")

work() {
	if "$create" && [ ! -f "$file" ]; then
		log 1 "Creating file $file with block contents"
		printf "%s\n" "$begin" "$block" "$end" > "$file"
		return
	fi
	assert '[ -f "$file" ]' "File $file does not exists"
	assert '[ -w "$file" ]' "File $file is not writable"
	
	if ! beginno=$(
		grep -n -x "$begin" "$file" |
		head -n1 | cut -d: -f1
	); then
		log 3 "begin=$beginno not found in file"
		log 1 "Appending the block to file=$file"
		printf "%s\n" "$begin" "$block" "$end" >> "$file"
		return 
	else
		log 2 "Beginning $begin found on line number $beginno"
	fi
	
	filelen=$(<"$file" wc -l)
	
	if ! endno=$(
		grep -n -x "$end" "$file" |
		tail -n1 | cut -d: -f1
	); then
		log 1 "Ending not found - wrongly input"
		exit 1
	else
		log 3 "Ending=$end found on line $endno"
	fi
	
	((endno == beginno)) && assert false "Regex fail - line with ending marger and beginning marker are the same line!"
	((endno < beginno)) && assert false "Bailing out - line with ending marger is lower then line number with beginning"
	assert '((beginno < endno))' "Ending number must be greater then beginning number"
	assert '((endno != 0))' "Logically ending number cannot be zero"
	assert '((beginno < filelen))' "Logically beginnnig number cannot be last line in file"
	
	if ! "$delete"; then
		tmp=$(mktemp)
		log 1 "Deleting lines $beginno to $endno from $file and substituting with block contents"
		if ((beginno + 1 != endno)); then
			sed -i -e "$((beginno + 1))"','"$((endno - 1))"'d' "$file"
		fi			
		sed -i -e "$beginno"' r'<(printf "%s\n" "$block") "$file"
	else
		log 1 "Deleting lines $beginno to $endno from $file"
		sed -i -e "$beginno"','"$endno"'d' "$file"
	fi
} # work

work

if [ -n "$validate" ]; then
	validate=$(printf -- "$validate" "$file")
	log 1 "Executing validate script '$validate'"
	if $validate; then
		log 3 "Validation successfull"
	else
		exit $?
	fi
fi

