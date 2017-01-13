#!/bin/bash -e
cryptdir=crypted
if ! grep -q "dupa" public/test-public.txt; then
	echo "public test failed."
fi
if ! grep -q "dupa" crypted/test-crypted.txt; then
	echo "cos jest nie tak! skrypt jest zaszyfrowany!!"
	exit 1
else
	echo "To repozytorium jest zdeszyfrowane poprawnie."
fi


if ! findmnt union 2>/dev/null >/dev/null ; then
	echo "and union directory not mounted!"
else
	echo "oraz union direcotry jest poprawnie zamontowany."
	if ! grep -q "dupa" union/test-crypted.txt ; then
		echo "unoin/test-encrypted.txt fail"
		exit 3
	fi
	if ! grep -q "dupa" union/test-public.txt ; then
		echo "union/test-public.txt fail"
		exit 4
	fi
fi

