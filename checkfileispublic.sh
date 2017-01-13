#!/bin/bash

file=$(readlink -f $1)
gittop=$(git rev-parse --show-toplevel)
echo         "Parsing $file"
file=$(echo "$file" | sed 's:^'"${gittop}"'\/\(union\|public\|crypted\)\/::' )
echo         "Checking file: union/$file"
echo;
if [ -e public/$file ]; then
	echo "Found file:    public/$file"
fi
if [ -e crypted/$file ]; then
	echo "Found file:    crypted/$file"
fi

