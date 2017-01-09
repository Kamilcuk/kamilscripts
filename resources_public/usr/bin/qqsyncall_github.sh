#!/bin/bash

user=${1:-Kamilcuk}

github_repos="$( curl https://api.github.com/users/$user/repos | grep html_url | sed 's/.*"html_url": "\(.*\)".*/\1/' | grep "https://github.com/$user/" | tr '\n' ' ')"

for i in $github_repos; do
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

