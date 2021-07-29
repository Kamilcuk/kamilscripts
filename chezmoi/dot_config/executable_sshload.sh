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
kcadd() {
	file_cmd "$1" "$KC/$1"
	cat <<EOF
echo "kc exe $1 loaded" >&2
EOF
}

kcadd l
kcadd ,lvm_resizer

cat <<'EOF'
if hash nvim 2>/dev/null >/dev/null; then
	alias vim=nvim
	export EDITOR=nvim
fi
shopt -s extglob
echo "sshload loaded" >&2
EOF



