#!/bin/bash
set -ueo pipefail
export SHELLOPTS

url=https://wiki.archlinux.org/index.php/unofficial_user_repositories
file=/tmp/.unofficial_user_repositories

usage() {
	cat <<EOF
Usage: 
	$0
	$0 signed
	$0 unsigned
	$0 keyid
EOF
}

set -x

curl -s -z "$file" -o "$file" "$url"
[ "$file" -nt "$file".text ] && html2text < "$file" > "$file".text

set -x

cat "$file".text |
sed -n '/Signed/,/Retrieved from/p' |
sed 's/^[[:space:]]*//' |
sed '/^$/d' |
sed 's/^* /# /' |
sed  's/###/\n###/' |
head -n-1 |
sed '/Adding your repository to this page/,/Signed/d' |
sed 's/^## /\n\n############################## /' |
sed '/Unsigned/{ :a; /^Server = /{ s/.*/&\nSigLevel = PackageOptional/; }; n; ba; }' |
sed '/^\(#.*\|[[:space:]]*\|\[.*\|Server = .*\|SigLevel = .*\)$/!{ s/^/# /; }' |
(
	case "${1:-}" in 
	signed) grep -A9999999 Signed | grep -B999999999 Unsigned | head -n-1 ; ;;
	unsigned) grep -A9999999 Unsigned; ;;
	keyid) grep 'Key-ID:' | awk '{print $3}'; ;;
	*) cat; ;;
	esac
)


