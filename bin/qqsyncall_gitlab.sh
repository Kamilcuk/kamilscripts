#!/bin/bash
set -e

etc=$(dirname $(readlink -f $0))/../etc/
. $etc/gitlab.env

gitlab_repos="$( curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" 'https://gitlab.com/api/v3/projects' | jq -r .[].ssh_url_to_repo)"

for i in $gitlab_repos; do
	repo="$(echo ${i//*\//} | sed 's/.git$//')"
	if [ -d $repo ]; then
		pushd $repo
		git pull
		popd
	else
		mkdir -p $repo
		git clone $i $repo
	fi
done

