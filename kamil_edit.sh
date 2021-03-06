#!/bin/bash
set -xuoe pipefail

if ! tmp=$(git remote -v | head -n1 | awk '{print $2}'); then
	echo "ERROR: problem getting git remote" >&2
	exit 1
fi

case "$tmp" in
"https://gitlab.com/Kamcuk/kamilscripts.git") ;;
"git@gitlab.com:Kamcuk/kamilscripts.git") ;;
*)
	echo "ERROR: wrong git remote $tmp - bailing out" >&2
	exit 1
esac

cd "$(dirname "$(readlink -f "$0")")"
if [ "$(pwd)" != /usr/lib/kamilscripts ]; then
	echo "ERROR: not in instalation dir" >&2
	exit 1
fi

chown kamil:kamil -R .
chown -v root:root etc/ssh/config
git remote set-url origin git@gitlab.com:Kamcuk/kamilscripts.git

