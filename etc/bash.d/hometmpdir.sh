#!/bin/bash

(

get_location() {
	if [[ -w /dev/shm ]]; then
		printf "%s" "/dev/shm"
	#elif [[ -w "${TMPDIR:-/tmp}" ]]; then
	#	printf "%s" "$TMPDIR"
	elif [[ -w /tmp ]]; then
		printf "%s" "/tmp"
	else
		return 1
	fi
}
logp() {
	echo "$(readlink -f "${BASH_SOURCE[0]}"): $*"
}
err() {
	logp "$*" >&2
}
create_new() {
	if ! d=$(get_location); then
		err "Could no get temporary location"
	else
		logp "Creating ~/tmp to symlink to $d/$n" >&2
		if ! {
			mkdir -p "$d/$n" 2>/dev/null &&
			ln -s "$d/$n" ~/tmp
		}; then
			err "Could not create $d/$n"
		fi
	fi
}

n=.$UID.home.tmp.dir
if [[ ! -L ~/tmp ]]; then
	if [[ ! -e ~/tmp ]]; then
		# Does not exists -> create one
		create_new
	else
		# Is not a symlink and exists, so it's a normal dir -> print error
		#err "~/tmp is not a symlink, bailing out"
		:
	fi
else
	# Is a symlink -> is it our symlink?
	v=$(readlink ~/tmp)
	if [[ "${v##*/}" != "$n" ]]; then
		# shellcheck disable=2088
		err '~/tmp is a symlink but not to where I want, bailing out'
	else
		# This resolves the symlink!
		if [[ ! -e ~/tmp ]]; then
			# Does not exists -> try to create it
			if ! mkdir "$v" 2>/dev/null; then
				# Creation with current failed? Recreate!
				rm ~/tmp &&
				create_new
			fi
		fi
	fi
fi


) ||:

