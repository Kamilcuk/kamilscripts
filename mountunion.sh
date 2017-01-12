#!/bin/bash -e

union=$(pwd)/union

mount_overlayfs() {
	# sadly i have zfs, overlayfs does not work on top zfs... :( buuuuuu!
	local tempdir=$(mktemp -d .kamil-scripts-repo.workdir.XXXXXXXXXX)
	if ! sudo mount -t overlay -o lowerdir="$(pwd)/public",upperdir="$(pwd)/crypted",workdir="${tempdir}" overlay $(pwd)/union ; then
		rmdir "${tempdir}"
		return 1
	fi
	return 0
}

mount_unionfs() {
	#sudo mount -t unionfs -o dirs=/tmp/dir1/=RW:/home/users/kamil/=RO unionfs /tmp/aufs-root/
	unionfs "$(pwd)/crypted"=RW:"$(pwd)/public"=RO "$union"
}

checkdirisempty() {
	# returns 0 if dir is empty
	[ "$(ls -A "$1")" ]
}

checkdirismounted() {
	findmnt "$1" >/dev/null 2>&1
}

usage() { 
	cat << EOF
	$0 -> mount
	$0 -u -> umount
EOF
}

case "$1" in
-u)
	echo "Unmounting action required."
	if ! checkdirismounted "$union" ; then
		echo "but $union is not mounted!"
		exit 2;
	fi
	fusermount -u $union
	echo "Success - unmounted $union"
	;;
*)
	[ -e ./union/.gitignore ] && rm ./union/.gitignore
	if checkdirisempty "$union" ; then
		echo "fail - $union directory is not empty!"
		exit 2
	fi
	if checkdirismounted "$union" ; then
		echo "fail - $union directory is already mounted!"
		exit 3
	fi
	if ! mount_unionfs ; then
		echo "mount failed!"
		exit 1
	fi
	echo "Success - mounted $union"
esac

