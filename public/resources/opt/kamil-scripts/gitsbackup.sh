#!/bin/bash
# Kamil Cukrowski (C) 2017. Under MIT License
#
# config ###################################################
set -euo pipefail

# priv config
DEBUG=${DEBUG:-false}
TEST=${TEST:-false}

$DEBUG && set -x
$TEST && git() { echo "git $*"; }

# functions ###############################################

usage() {
	n=gitsbackup.sh
	cat >&2 <<EOF
Usage:
	$n <backup dir> <config>...

Backups all found repositories into backup dir, using:
'git clone --mirror and git remote update'.
Every backuped repository is stored inside a directory path
created from repository url.

Config:
	Every config argument is of a format:
		arg1:arg2[:arg3...]
	Config contains arguments to function getAllRepos defined inside the script.

Examples:
	$n /tmp/ github.com:UserName gitlab.com:GITLAB_PRIVATE_TOKEN

Written by Kamil Cukrowski (C) 2017. Under MIT License.
EOF
}

if hash jq 2>/dev/null; then
	jq_get() { jq -r ".[].$1"; }
else
	jq_get() { tr , '\n' | sed -ne '/"'"$1"'"[[:space:]]*:[[:space:]]*"/s/.*"'$1'"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p'; }
fi

getAllRepos() {
	# download all repos belonging to specified user/token on specified site
	case "$1" in
	gitlab.com) curl -s --header "PRIVATE-TOKEN: $2" 'https://gitlab.com/api/v3/projects' | jq_get ssh_url_to_repo; ;;
	github.com) curl -s "https://api.github.com/users/$2/repos" | jq_get ssh_url; ;;
	esac
}

backup_repos() {
	local output="$1" dir url
	shift

	for url; do
		dir="$output/$url"
		echo "backup_repos: $dir"

		if [ ! -d "$dir" ]; then
			git clone --mirror "$url" "$dir"
		fi
		git --git-dir="$dir" remote update

	done
}


# main #######################################################################

if [ "$#" -lt 2 ]; then usage; exit 1; fi;
if [ "$(whoami)" != "kamil" ]; then exec sudo -u kamil "$0" "$@"; fi

ionice -c 3 -p $BASHPID >/dev/null # set Idle I/O scheduling priority
renice -n 5 -p $BASHPID >/dev/null # set niceness level

# input arguments config
OUTPUTDIR="$1"
shift

# load repos list
repos=""
for i; do
	args=( $(echo "$i" | tr ':' ' ') )
	echo "Getting all repos from ${args[0]}"
	add=$(getAllRepos "${args[@]}")
	if [ -z "$add" ]; then
		echo "ERROR config argument "$i" resulted in 0 repos"
		exit 1
	fi
	repos+=" $add"
done

echo "Found $(wc -w <<<$repos) repos to backup."
$TEST && echo $repos

# backup repos
backup_repos "$OUTPUTDIR" $repos

wait
echo
echo "Success!"

