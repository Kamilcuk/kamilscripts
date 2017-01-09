#!/bin/bash -xe
if ! grep -q "dupa" resources_public/usr/lib/kamil-scripts/test-public.txt; then
	echo "public test failed."
fi
if ! grep -q "dupa" resources_crypted/usr/lib/kamil-scripts/test-encrypted.txt; then
	echo "cos jest nie tak! skrypt jest zaszyfrowany!!"
	exit 1
else
	echo "Jest encrypted!"
	echo "Jest OK!"
fi

