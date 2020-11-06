#!/bin/bash

is_installed() {
	pacman -Qi "$1" >/dev/null 2>&1
}
package_exists() {
	pacman -Si "$1" >/dev/null 2>&1
}
install_it() {
	pacman -S --noconfirm python-"$1"
}

version=2
echo "version=pip$version"

pip$version list | awk '{print $1}' |
while read -r p; do
	n=python$version-$p
	if ! is_installed $n && package_exists $n; then
		echo $p
		echo $p will be moved >&2
	else
		echo $p is fine >&2
	fi
done |
paste -sd' ' |
while IFS= read -r l; do
	echo "sudo pip uninstall -y $l"
	l=$(<<<"$l" tr ' ' '\n' | xargs -i echo python-{} | paste -sd' ')
	echo "sudo pacman -S --noconfirm $l"
done

