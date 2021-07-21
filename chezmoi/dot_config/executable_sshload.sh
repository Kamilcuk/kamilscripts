#!/bin/bash
set -euo pipefail
shopt -s extglob

file_cmd() {
	cmd="$1"
	file="$2"
	echo "unalias $cmd 2>/dev/null"
	filecontent=$(base64 -w0 "$file")
	(
	eval "
function $cmd() ("'
	local tmp=$(mktemp)
	trap "command rm \"$tmp\"" EXIT
	chmod +x "$tmp"
	echo '"$filecontent"' | base64 -d > "$tmp"
	"$tmp"
)
'
	declare -f "$cmd"
	)
}

KC=~/.config/kamilscripts/kamilscripts/bin
#'ls -alhF --color=auto --group-directories-first'
file_cmd l $KC/l 
cat <<EOF
if hash nvim 2>/dev/null >/dev/null; then
	alias vim=nvim
	export EDITOR=nvim
fi
shopt -s extglob
echo "sshload loaded" >&2
EOF



