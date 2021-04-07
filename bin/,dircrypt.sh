#!/bin/bash
set -euo pipefail

parse_args() {
	g_gpgargs=(gpg)
	if [[ "$1" = "-p" ]]; then
		if [[ -e "$2" ]]; then
			g_gpgargs+=(--passphrase-file "$2" --batch --yes)
		fi
		shift 2
	fi
	if (($# != 2)); then
		L_fatal "Two arguments required: dirtocompress + destinationfilename"
	fi
	g_dir=$1
	g_dirdirname=$(dirname "$g_dir")
	g_dirbasename="$(basename "$g_dir")"
	g_output=${2%.tar.gpg}.tar.gpg
}

super_gpg() {
	set -- "${g_gpgargs[@]}" "$@"
	L_log "+" "multi" "$@"
	eval "tempfunc() { $(printf "%q " "$@"); }"
	str='tempfunc'
	for ((i=1;i<3;++i)); do
		str+=" | tempfunc"
	done
	eval "$str"
}

_tar() {
	L_logrun tar "$@"
}

C_encrypt() {
	parse_args "$@"
	_tar --owner=0 --group=0 -c -v -C "$g_dirdirname" "$g_dirbasename" | super_gpg \
		--force-mdc \
		--s2k-cipher-algo AES256 \
		--s2k-digest-algo SHA512 \
		--s2k-mode 3 \
		--s2k-count 65011712 \
		-c - > "$g_output"
}

C_decrypt() {
	parse_args "$@"
	super_gpg -d - < "$g_output" | _tar -x -v -C "$g_dirdirname"
}

c_info() {
	T_logrun "${g_gpgargs[@]}" --list-packets "$g_output"
}

C_d() { C_decrypt "$@"; }
C_e() { C_encrypt "$@"; }

. ,lib_lib "C_" "$@"

