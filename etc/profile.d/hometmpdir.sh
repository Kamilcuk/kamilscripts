#!/bin/sh

# shellcheck disable=2088
if [ -e ~ ]; then
	(

logp() {
	echo "hometmpdir.sh: $*" >&2
}

create_new() {
	if [ -w /dev/shm ]; then
		destdir="/dev/shm"
	elif [ -w /tmp ]; then
		destdir="/tmp"
	else
		logp "Could not get temporary directory location"
		return
	fi


	logp "Creating ~/tmp to symlink to $destdir/$dirname"
	if [ ! -e "$destdir/$dirname" ]; then
		if ! \mkdir "$destdir/$dirname"; then
			logp "Could not create $destdir/$dirname directory"
			exit 1
		fi
	fi
	if ! \ln -vsn "$destdir/$dirname" ~/tmp; then
		logp "Could not create ~/tmp -> $destdir/$dirname symlink"
		exit 1
	fi
}

dirname=".$(id -u).home.tmp.dir"
if [ ! -L ~/tmp ]; then
	if [ ! -e ~/tmp ]; then
		# Does not exists -> create one
		create_new
	else
		# Is not a symlink and exists, so it's a normal dir -> print error
		logp "~/tmp is not a symlink, bailing out"
		exit 1
	fi
else
	# Is a symlink -> is it our symlink?
	linkdest=$(readlink ~/tmp)
	if [ "${linkdest##*/}" != "$dirname" ]; then
		logp "~/tmp is a symlink but not to where I want, bailing out. $linkdest $dirname"
		exit 1
	else
		# This resolves the symlink!
		if [ ! -e ~/tmp ]; then
			# Destination does not exists -> try to create it
			if ! \mkdir "$linkdest"; then
				# Creation with current failed? Recreate!
				\rm ~/tmp &&
				create_new
			fi
		fi
	fi
fi

	) || :
fi

