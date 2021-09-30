#!/bin/bash

tmpd=/tmp/tmp.icon_browser
trap_exit() {
	set -x
	rm -rf "$tmpd"
}
trap 'trap_exit' EXIT

echo "Creating temporary directory..."
find /usr/share/icons /usr/share/pixmaps ~/.icons \
	-type f '(' -name '*.xpm' -o -name '*.svg' -o -name '*.png' ')' \
	-printf '%p\t%f\0' |
	sort -z -k2 |
	uniq -z -f1 | 
	tr '\t' '\0' | {
		cd "$tmpd" &&
		xargs -0 -n2 -P32 ln -nfs
	}
xdg-open "$tmpd"
echo "Press enter to remove temporary directory..."
read -r


