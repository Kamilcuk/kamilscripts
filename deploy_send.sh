#!/bin/bash
set -euo pipefail
set -x
cd $(readlink -f $(dirname $(readlink -f $0)))
host=$1
f=$(ls -t ./pkg-archlinux/*.pkg.tar.xz)
f=$(printf "%s\n" $f | head -n1)
n=$(basename $f)
scp $f $host:/tmp/$n
ssh $host "/bin/bash -c \"sudo pacman -U \\\"/tmp/$n\\\" && rm -v \\\"/tmp/$n\\\" \""

