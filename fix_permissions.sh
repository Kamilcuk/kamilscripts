#!/bin/bash

echo=""
case "$1" in
-o|-k|--ok) ;;
*)
	cat <<EOF
Script used to fix permissions when cloning from owncloud.
Add -o or -k or --ok command line to actually make changes.

EOF
	echo=echo
	;;
esac

git diff --summary |
	awk '/mode change/{print gensub(/.../,"","1",$3), $6}' |
	xargs -r -n2 $echo chmod -v

