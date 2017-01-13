#!/bin/bash -e


#gitdir=$(GIT_DISCOVERY_ACROSS_FILESYSTEM=yes git rev-parse --show-toplevel)
gitdir="$(dirname $(dirname $(readlink -f "$0")))"
cd $gitdir
uniondir=./pkg-archlinux/src/
./pkg-archlinux/rsync_all_pkg_resources.sh

files=( $(cd "$(readlink -f $uniondir)" && find -type f | sed 's/^\.\///g' ) )

case "$1" in
-d)
        str=""
        for f in "${files[@]}"; do
                if [ ! -e /${f} ]; then
                        echo "/${f}: No such file."
                        continue;
                fi
                if ! cmp /${f} $uniondir/${f} >/dev/null 2>&1; then
                        diff -u --color -- $uniondir/${f} /${f}
                fi
        done
	;;
-a)
	str=""
	for f in "${files[@]}"; do
		if [ ! -e /${f} ]; then
			echo "/${f}: No such file."
			continue;
		fi
		if ! cmp /${f} $uniondir/${f} ; then
			str+="/${f} "
		fi
	done
	
	echo;
	if [ -z "$str" ]; then
		echo "No files differ!"
	else
		echo "To add files to packages type following command:"
		echo "./add_files_to_package.sh [public|crypted] $str"
	fi
	;;
*)
	# uasge()
	cat << EOF 

USAGE:	./get_changed_files.sh [-d|-a]
	
	pokazuje jakie pliki sie zmienily
EOF
esac
