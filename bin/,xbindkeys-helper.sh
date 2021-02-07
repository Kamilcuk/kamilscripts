#!/bin/bash

# This is a small helper run from my xbindkeys shortcuts

html-quote() {
	sed '
		s/\&/\&amp;/g
		s/</\&lt;/g
		s/>/\&gt;/g
	'
}

if (($# >= 2)); then
	text=$1
	shift
else
	text=""
fi

if hash notify-send 2>/dev/null >/dev/null; then
	notify-send -u low -i forward -t 2000 "xbindkeys" "$(cat <<EOF
${text:+<big><b>    $(html-quote <<<"$text")</b></big>
}<small>Running: <tt>$(html-quote <<<"$*")</tt></small>
EOF
)"
fi

bash -x -c "$*"

