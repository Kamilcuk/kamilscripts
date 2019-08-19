#!/bin/bash
set -euo pipefail
export SHELLOPTS

# functions ############################################

get_bool() {
	case "$1" in
	[Tt][Rr][Uu][Ee]|1) echo true; ;;
	[Ff][Aa][Ll][Ss][Ee]|0) echo false; ;;
	*) fatal "get_bool(): Invalid boolean value: $1"; ;;
	esac
}

is_true() {
	local tmp
	tmp=$(get_bool "$1")
	[ "$tmp" = true ]
}

is_false() {
	! is_true "$1"
}

fatal() {
	IFS=' '
	printf "%s\n" "$*" >&2
	exit 1
}

assert() {
	if [ -z "$1" ] || ! eval "$1"; then
		fatal "ERROR: Assertion $1 failed: ${@:2}\n" >&2
	fi
}

#debug stream
dbgs() {
	tee >(sed 's/^/'"${1:-dbg}"': /' >&2)
}
dbgt() {
	if [ "${DEBUG:-false}" = "true" ]; then
		echo "==> $2 <=="
		column -t -s$'\t' -o ' | ' -N "$1" "$2"
		echo
	fi
}

# getopt ################################################################################

# defaults
rtl_files=()
exclude=()
dot=false
include_unknowns=false
temp_dir=""
references=true
references_ascend=false
table=true

usage() {
	local n
	n=$(basename "$0")
	cat <<EOF
Usage: $n [options]

Options:
  -D --dot=BOOL               Output in dot(1) compatible format. Default: $dot
  -U --include-unknowns=BOOL  Include function which are from shared libraries. Default: $include_unknowns
  -e --exclude=STR            Add function to ignore list. Default: empty.
  -t --temp-dir=STR           Use this directory instead of temporary one. Deftaul: mktemp -d
  -h --help                   Print this text and exit.
  -R --references=BOOL        Include references to functions. Default: $references.
  -A --references-ascend=BOOL Ascend into references when calculating stack usage. Default: $references_ascend
  -T --table=BOOL             Print output in a nice looking table. Default: $table

Examples:
  $n -U1 -D1 -e__stack_chk_fail -R0 shell.ltrans0.234r.expand

Written by Kamil Cukrowski
Licensed under GPL license.
EOF
}

args=$(getopt -n "$(basename "$0")" \
	-o D:U:e:t:hR:A:T: \
	-l dot:,include-unknowns:,exclude:,temp-dir:,help,references:,references-ascend:,table: -- "$@")
eval set -- "$args"

while (($#)); do
	case "$1" in
	-D|--dot) dot=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-U|--include-unknows) include_unknowns=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-R|--references) references=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-t|--temp-dir) temp_dir=$2; shift; ;;
	-e|--exclude) exclude+=("$2"); shift; ;;
	-h|--help) usage; exit 0; ;;
	-R|--references) references=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-A|--references-ascend) references_ascend=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-T|--table) table=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	--) shift; break; ;;
	*) fatal "Error parsing arguments: $1"; ;;
	esac
	shift
done

rtl_files=("$@")

assert '[ "${#rtl_files[@]}" -gt 0 ]' "No rtl files specified. See $0 --help"

for i in "${!rtl_files[@]}"; do
	tmp=${rtl_files[$i]}
	assert '[ -r "$tmp" ]' "File $tmp is not readable"
	rtl_files[$i]=$(readlink -f "$tmp")
done

if [ -z "$temp_dir" ]; then
	tmpd=$(mktemp -d)
	trap 'cd /; rm -rf "$tmpd"' EXIT
else
	tmpd="$temp_dir"
fi
mkdir -p "$tmpd" || fatal 'Could not create the temporary directory "$tmpd"'

## main #######################################################################################

# calls.txt: <function> <call|ref> <other_function>
sed -nE '
	# hold function name
	# ex. ;; Function function_cd (function_cd, funcdef_no=13, decl_uid=4342, cgraph_uid=5, symbol_order=74)
	/^;; Function (\w+).*/{
		s//\1/
		h
		s/$/\tFunction/
		p
		d
	};

	# call a function
	# for each call print that the function calls the function
	# ex. (call (mem:QI (symbol_ref:DI ("getcwd") [flags 0x41]  <function_decl 0x7ffba1f89200 getcwd>) [0 getcwd S1 A8])
	/^.*\((call) [^"]+"(\w+).+<function_decl .*/b print

	# takes a pointer to a function
	# ex. (symbol_ref:DI ("alphasort") [flags 0x41]  <function_decl 0x7ffba1f87400 alphasort>)
	/^[^(]+\(symbol_(ref)[^"]+"(\w+)[^<]+<function_decl .*/b print

	# uses stack
	# ex. Partition 0: size 8 align 8
	/^(Partition) [0-9]+: size ([0-9]+).*/b print
	
	# if we didnt match anything, we start new
	d

	# if we match anything branch here
	: print
	{
		# so the match has to set the \1 match
		s//\1\t\2/
		G
		s/(.*)\n(.*)/\2\t\1/
		p
	}

' "${rtl_files[@]}" |
if [ "${#exclude[@]}" -eq 0 ]; then
	cat
else
	sort -t$'\t' -k1 | 
	join -t$'\t' -v1 -11 -21 -o1.1,1.2,1.3 - <(
		printf "%s\n" "${exclude[@]}" | sort
	) |
	sort -t$'\t' -k3 |
	join -t$'\t' -v1 -13 -21 -o 1.1,1.2,1.3 - <(
		printf "%s\n" "${exclude[@]}" | sort
	)
fi > parsed.txt

# stack.txt: <function> <stack usage>
awk -v OFS=$'\t' '{ $2 == "Partition" && sum[$1]+=$3; } END { for (key in sum) print key,sum[key]; }' parsed.txt |
	sort -t$'\t' -k1 > stack.txt
dbgt 'function,stack_usage' stack.txt

# calls.txt: <function> <call|ref> <other_function> <count>
awk '$2 == "call" || $2 == "ref"' parsed.txt |
	sort |
	uniq -c |
	sed -E 's/^[[:space:]]+([0-9]+) (.*)$/\2\t\1/' > calls.txt
dbgt 'function,type,calls,count' calls.txt

rm parsed.txt

# remove functions that we don't know the stack usage of
# joined.txt: <function> <call|ref> <other_function> <count> <stack_usage_of_other_function>
tmp=()
if is_true "$include_unknowns"; then
	tmp=(-e? -a1)
fi
join -t$'\t' -13 -21 "${tmp[@]}" -o1.1,1.2,1.3,1.4,2.2 <(sort -t$'\t' -k3 calls.txt) stack.txt > joined.txt
dbgt 'function,type,calls,count,add_stack' joined.txt

if is_true "$dot"; then
	echo "digraph G {"

	{
	while IFS=$'\t' read -r func cost; do
		printf "%s [label=\"%s\\\\nstack=%s\"]\n" "$func" "$func" "$cost"
	done < stack.txt
	while IFS=$'\t' read -r func type calls count add_stack; do
		attributes=()

		if [ "$type" = "ref" ]; then
			attributes+=('style=dashed')
		fi

		if [ "$count" != 1 ]; then
			attributes+=("label=\"$count\"")
		fi

		if [ "${#attributes[@]}" -gt 0 ]; then
			attributes=$(
				IFS=' '
				printf " [%s]\n" "${attributes[*]}"
			)
		else
			attributes=""
		fi

		printf "%s -> %s%s\n" "$func" "$calls" "$attributes"

	done < joined.txt 
	} |
	sed 's/^/\t/; s/$/;/'

	echo '}'

	exit
fi

# Get the heads of the callgraph. Can be many.
comm -23 <(cut -f1 joined.txt | sort -u) <(cut -f3 joined.txt | sort -u) | sort -u > heads.txt
awk '$2 == "ref"' joined.txt | cut -f3 >> heads.txt
dbgt 'function' heads.txt

# tail -n+1 heads.txt stack.txt joined.txt

# yea recursive
f() {
	if ! grep "^$1"$'\t' joined.txt; then
		:
	fi |
	while IFS=$'\t' read -r func type calls count cost; do
		if [ "$func" = "$calls" ]; then
			echo "$func is recursive"
			continue
		fi
		
		case "$type" in
		ref)  type="-?"; ;;
		call) type="->"; ;;
		*) assert false ''; ;;
		esac

		callstack="$2$type$calls"
		cost="$3+$cost"

		if [ "$type" = "->" ]; then
			f "$calls" "$callstack" "$cost"
		else
			if is_true "$references_ascend"; then
				f "$calls" "$callstack" "$cost"
			elif is_true "$references"; then
				printf "%s\t%s\n" "$callstack" "$cost"
			fi
		fi

	done
	if [ -n "$2" ] && ! grep -q "^$1"$'\t' joined.txt; then
		printf "%s\t%s\n" "$2" "$3"
	fi
}

while IFS= read -r head; do 
	f "$head" "$head" "$(<stack.txt grep "^$head"$'\t' | cut -f2 || echo 0)"
done < heads.txt |
while IFS=$'\t' read a b; do
	printf "%s\t%s\t%s\n" "$a" "$b" "$(<<<$b tr '?' '0' | bc)"
done |
sort -t$'\t' -n -k3 |
if is_false "$table"; then
	cat
else 
	column -t -s$'\t' -o' | ' -N "callchain,callcost,sum" |
	{
		IFS='|' read -r -a line

		( IFS='|'; printf "%s\n" "${line[*]}"; )
		for i in "${!line[@]}"; do
			line[$i]=$({ yes '-' | head -n "${#line[$i]}" ||:; } | tr -d '\n')
		done
		( IFS='|'; printf "%s-\n" "${line[*]}"; )

		cat
	}
fi
