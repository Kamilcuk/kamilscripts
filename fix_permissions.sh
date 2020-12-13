#!/bin/bash

cmd=()
if [[ "${1:-}" != --ok ]]; then
	cat <<EOF
Script used to fix permissions when cloning from owncloud.
Add --ok command line to actually make changes.

EOF
	cmd=(echo)
fi

# Fix missing permissions
git diff | 
	grep -A1 -B1 'old mode' |
	grep 'diff --git' |
	sed 's/.*i\/\([^ ]*\).*/\1/' |
	{
		if ! IFS= read -r line; then
			echo "Nothing to be done..."
		else
			{
				printf "%s\n" "$line"
				cat
			} | xargs -- "${cmd[@]}" chmod +x
		fi
	}

