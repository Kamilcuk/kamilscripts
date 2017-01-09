#!/bin/bash -e

########################## funcions ########################3

usage() {
	cat << EOF
Usage: qqqoutify.sh -
Embed standard input in quotes.

Example:
	$ echo urxvt -fg '#111111' -bg '#111111'
	urxvt -fg #111111 -bg #111111
        $ echo 'urxvt -fg '"'"'#111111'"'"' -bg '"'"'#111111'"'"
	urxvt -fg '#111111' -bg '#111111'
	$ echo 'urxvt -fg '"'"'#111111'"'"' -bg '"'"'#111111'"'" | ./qqqoutify.sh -
	'urxvt -fg '"'"'#111111'"'"' -bg '"'"'#111111'"'"

Environmental settings:
	QQQOUTIFY_MODE
		=single
			escape "'\"" with '"'"'"'\""'
		=singleone (default)
			escape "'\"" with '"'\''\""'
		=double
			escape "'\"" with "\"'\\\"\""
		=all
			print all outputs
		=test
			print all outputs, then get output from echo

EOF
}

single() {
	# ' -> '"'"'
        sed -e "
s/'/'\"'\"'/g
# add ' to start and end
s/^/'/
s/$/'/
# remove empty '' at the beggining and and
s/^''//
s/''$//
"
}

singleone() {
        # ' -> '"'"'
        sed -e "
s/'/'\\\''/g
# add ' to start and end
s/^/'/
s/$/'/
# remove empty '' at the beggining and and
s/^''//
s/''$//
"
}

double() {
	# all escape needed things, need escaping, so: $ -> \$ and " -> \"
	sed '
s/\([$\\"]\)/\\\1/g
# add " to start and end
s/^/"/
s/$/"/
# remove empty "" at the beggining and and, but not if they are escaped
s/^"[^\]"//
s/[^\]""$//
'
}

######################## main ##########################

[ $# -eq 0 ] && usage && exit 1

QQQOUTIFY_MODE=${QQQOUTIFY_MODE:-singleone}

case $QQQOUTIFY_MODE in
single|singleone|double)
	cat | $QQQOUTIFY_MODE
	;;
all|test)
	# test with $ echo '"'\''\\""' | QQQOUTIFY_MODE=test ./qqqoutify.sh -
	if [ $QQQOUTIFY_MODE == "test" ]; then
		test=true
	else
		test=false
	fi
	while IFS= read line; do
		if $test; then
			printf "%20s <> %s\n" "Got string" "$line"
		fi
		for i in single singleone double; do
			printf "%20s -> " "$i"
			echo "$line" | $i
			if $test; then
				$test && printf "%20s <- " "test back -^- "
				eval echo $(echo "$line" | $i)
			fi
		done
	done
	;;
*)
	echo " ERROR: Wrong QQQOUTIFY_MODE value: \"$QQQOUTIFY_MODE\" " 2>&1
	;;
esac

