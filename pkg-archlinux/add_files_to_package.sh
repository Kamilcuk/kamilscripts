#!/bin/bash -e

_get_dst() {
	echo -n "$1/resources/$2" | sed 's/\/\//\//g'
}
get_dst_other() {
	if [ "$ftype" = public ]; then
		_get_dst crypted $1
	else
		_get_dst public $1
	fi
}
get_dst() {
	_get_dst $ftype $1
}
get_dstdir() {
	echo -n "$(dirname "$(get_dst $1)")"
}

## ftype get public or crypted
ftype=$1
case $ftype in
	public|crypted) : ;;
	*) echo "Wrong first argument $ftype;"; exit 1; ;;
esac
shift

## parse input -- set locals
#gitdir=$(GIT_DISCOVERY_ACROSS_FILESYSTEM=yes git rev-parse --show-toplevel)
gitdir="$(dirname $(dirname $(readlink -f "$0")))"
cd $gitdir

srcs=( "$@" )
dstdirs=()
for f in "${srcs[@]}"; do
	dstdirs+=( "$(get_dstdir "$f")" )
done
dstdirs=( $(echo "${dstdirs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

## 
for f in "${srcs[@]}"; do
	if [ ! -r "$f" ]; then
		echo "ERROR - $f is not readable."
		exit 1
	fi
done
##
for d in "${dstdirs[@]}"; do
	if [ ! -d "$d" ]; then
		echo "Will create dir $d"
	fi
done
##
for f in "${srcs[@]}"; do
	if [ -e "$(get_dst "$f")" ]; then
		echo "Will overwrite $f to existing $(get_dst "$f")"
	else
		echo "Will copy $f to $(get_dst "$f")"
	fi
	if [ -e "$(get_dst_other "$f")" ]; then
		echo "Note: $(get_dst_other "$f") also exists"
	fi
done

echo "Actions above will be done, are you sure? [y]"
read a
[ "$a" != 'y' ] && exit 0

for f in "${srcs[@]}"; do
	dstdir="$(get_dstdir "$f")"
	dst="$(get_dst "$f")"
	if [ ! -d "$dstdir" ]; then
		( set -x
		mkdir -p $dstdir
		)
	fi
	( set -x
	cp -a "$f" $dst
	)
done

