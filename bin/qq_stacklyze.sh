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

verbose() {
	if [ "${verbose:-false}" = "true" ]; then
		printf "==> %s %s\n" "$(date +%s.%N) $*" >&2
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
tempdir=""
references=true
references_ascend=false
table=true
headregex=""
excluderegex=""
verbose=false
dot_clusters=true

usage() {
	local n
	n=$(basename "$0")
	cat <<EOF
Usage: $n [options]

Options:
  -D --dot=BOOL               Output in dot(1) compatible format. Default: $dot
  -U --include-unknowns=BOOL  Include function which are from shared libraries. Default: $include_unknowns
  -e --exclude=STR            Add function to ignore list. Default: empty.
  -p --tempdir=STR            Use this directory instead of temporary one. Deftaul: mktemp -d
  -h --help                   Print this text and exit.
  -R --references=BOOL        Include references to functions. Default: $references.
  -A --references-ascend=BOOL Ascend into references when calculating stack usage. Default: $references_ascend
  -T --table=BOOL             Print output in a nice looking table. Default: $table
  -H --headregex=STR          Heads are only those that conform to this regex. Parsed with grep -E.
  -E --excluderegex=STR       Exclude all functions that conform to this regex. Parsed with grep -E.
  -v --verbose                Try to print something
  -C --dot-clusters=BOOL      Group similar functions into clusters in dot output. Default: $dot_clusters

BOOL can be "0", "false", "1" or "true".

Examples:
  $n -U1 -D1 -e__stack_chk_fail -R0 shell.ltrans0.234r.expand

Written by Kamil Cukrowski
Licensed under GPL license.
EOF
}

args=$(getopt -n "$(basename "$0")" \
	-o D:U:e:p:hR:A:T:H:E:vC: \
	-l dot:,include-unknowns:,exclude:,tempdir:,help,references:,references-ascend:,table:,headregex:,excluderegex:,verbose,dot-clusters: \
	-- "$@"
)
eval set -- "$args"

while (($#)); do
	case "$1" in
	-D|--dot) dot=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-U|--include-unknows) include_unknowns=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-R|--references) references=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-p|--tempdir) tempdir=$2; shift; ;;
	-e|--exclude) exclude+=("$2"); shift; ;;
	-h|--help) usage; exit 0; ;;
	-R|--references) references=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-A|--references-ascend) references_ascend=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-T|--table) table=$(get_bool "$2") || fatal "Error parsing argument: $1$2"; shift; ;;
	-H|--headregex) headregex="$2"; shift; ;;
	-E|--excluderegex) excluderegex="$2"; shift; ;;
	-v|--verbose) verbose=true; ;;
	-C|--dot-clusters) dot_clusters="$2"; shift; ;;
	--) shift; break; ;;
	*) fatal "Error parsing arguments: $1 <- $args"; ;;
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

if [ -z "$tempdir" ]; then
	tmpd=$(mktemp -d)
	trap 'cd /; rm -rf "$tmpd"' EXIT
	verbose "Created temporary directory: $tmpd"
else
	verbose "Using user supplied temporary directory: $(readlink -f tmpd)"
	tmpd="$tempdir"
fi
mkdir -p "$tmpd" || fatal 'Could not create the temporary directory "$tmpd"'
cd "$tmpd"

## main #######################################################################################

for i in "${!rtl_files[@]}"; do
	verbose "Input file $i: ${rtl_files[$i]}"
done

verbose "first parsing stage - get everything usefull from rtl files in parsable format"
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
{

	# buh, I have no better idea
	buf=$(cat)

	if [ -n "$excluderegex" ]; then
		tmp=$(<<<"$buf" cut -f1,3 | tr '\t' '\n' | sort -u)
		IFS=$'\n' tmp=($tmp)
		exclude+=("${tmp[@]}")
	fi
	
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
	fi <<<"$buf"

} > parsed.txt
dbgt 'function,bla,bla,bla' parsed.txt
assert '[ -s parsed.txt ]' "Found no function definitions in the input files. Check your input."

verbose "stack.txt: <function> <stack usage>"
awk -v OFS=$'\t' '
	{ 
		$2 == "Function" && sum[$1]=0;
		$2 == "Partition" && sum[$1]+=$3;
	}
	END {
		for (key in sum)
			print key,sum[key];
	}' parsed.txt |
	sort -t$'\t' -k1 > stack.txt
dbgt 'function,stack_usage' stack.txt

# calls.txt: <function> <call|ref> <other_function> <count>
awk '$2 == "call" || $2 == "ref"' parsed.txt |
	sort |
	uniq -c |
	sed -E 's/^[[:space:]]+([0-9]+) (.*)$/\2\t\1/' > calls.txt
dbgt 'function,type,calls,count' calls.txt

# remove functions that we don't know the stack usage of
verbose "joined.txt: <function> <call|ref> <other_function> <count>"
tmp=()
if is_true "$include_unknowns"; then
	tmp=(-e? -a1)
fi
join -t$'\t' -13 -21 "${tmp[@]}" -o1.1,1.2,1.3,1.4 <(sort -t$'\t' -k3 calls.txt) stack.txt > joined.txt
dbgt 'function,type,calls,count' joined.txt

verbose "Get the heads of the callgraph"
{
	comm -23 <(cut -f1 joined.txt | sort -u) <(cut -f3 joined.txt | sort -u)
	if is_true "$references"; then
		awk '$2 == "ref"' joined.txt | cut -f3
	fi
} | 
sort -u |
if [ -n "$headregex" ]; then
	grep -E "$headregex"
else
	cat
fi > heads.txt
dbgt 'function' heads.txt
assert '[ -s "heads.txt" ]' "We found no heads in the linked graph of files. Check -H option."


run_awk() {
	cat >input.awk <<'AWK_SCRIPT_EOF'
BEGIN {
	FS = OFS = "\t"
}
FILENAME == "joined.txt" {
	++edgescnt[$1]
	type[ $1, edgescnt[$1]] = $2
	edges[$1, edgescnt[$1]] = $3
	count[$1, edgescnt[$1]] = $4
	next
}
FILENAME == "stack.txt" {
	costs[$1] = $2
	next
}	

function dot(node, i) {
	if (!(node in visited)) {
		visited[node]
		printf "\t" node " [label=\"" node "\\nstack=";
		if (node in costs) {
			printf costs[node]
		} else {
			printf "?"
		}
		printf "\"];\n"
	}

	for (i = 1; i <= edgescnt[node]; ++i) {
		attributes = ""

		if (type[node, i] == "ref") {
			attributes = attributes " style=dashed"
		}

		if (count[node, i] > 1) {
			attributes = attributes " label=\"" count[node, i] "\""
		}

		if (length(attributes) > 0) {
			attributes = " [" attributes "]"
		}


		if (!((node, i) in visited)) {
			visited[node, i]
			print "\t" node " -> " edges[node, i] attributes ";"
			dot(edges[node, i])
		}
	}
}

function generate(node, connstr, cost, sum, sep1, sep2, i) {
	thiscost = node in costs ? costs[node] : 0
	connstr = connstr sep1 node
	cost = cost sep2 thiscost
	sum += thiscost

	if (edgescnt[node] == 0 || node in visited) {
		print connstr, cost, sum
	} else {
		visited[node]
		for (i = 1; i <= edgescnt[node]; ++i) {
			sep = type[node, i] == "ref" ? "?" : ">"
			generate(edges[node, i], connstr, cost, sum, "-" sep, "+")
		}
		delete visited[node]
	}
}

function generate_visited(node, i) {
	if (!((node, i) in visited)) {
		visited[node, i]
		print node
		for (i = 1; i <= edgescnt[node]; ++i) {
			generate_visited(edges[node, i])
		}
	}
}
AWK_SCRIPT_EOF

	awk -f input.awk -f - joined.txt stack.txt heads.txt
}

if is_true "$dot"; then
	verbose "Generating dot graph"
	echo 'digraph G {'
	printf '\trankdir=LR;\n'
	if is_true "$dot_clusters"; then
		run_awk <<<'{ generate_visited($1) }' |
		# extract the prefic - the part before _
		sed -nE 's/^([^_]{1,})_.*/\1\t&/p' |
		# sort them on the prefix and get unique only
		sort -t$'\t' -u -k2,2 |
		# print the subgraph cluster_* things
		awk '{
			if (last == $1) {
				printf "\t\t" $2 ";\n";
			} else {
				if (length(last) != 0) {
					printf "\t}\n";
				}
				last=$1;
				printf "\tsubgraph cluster_" $1 " {\n";
				printf "\t\tlabel = \"" $1 "\";\n"
				# printf "\t\tcolor = \"blue\";\n"
				printf "\t\tcolor = \"#%02x%02x%02x\";\n", rand() * 100, rand() * 100, rand() * 100
				printf "\t\tstyle = \"bold\";\n"
				printf "\t\t" $2 ";\n";
			}
		}
		END{
			if (length(last) != 0) {
				print "\t}";
			}
		}'
	fi
	run_awk <<<'{ dot($1) }'
	echo '}'
	verbose "dot mode end"
	exit
fi

verbose "Entering recursive stage"
run_awk <<<'{ generate($1) }' |
sort -t$'\t' -n -r -k3,3 |
sort -t- -u -k1,1 |
sort -t$'\t' -n -k3,3 |
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
