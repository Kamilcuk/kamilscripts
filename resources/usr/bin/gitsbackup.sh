#!/bin/bash
# Kamil Cukrowski (C) 2017. Under MIT License
#
# config ###################################################
set -euo pipefail

# priv config
: ${DEBUG:=false}
: ${TEST:=false}
: ${VERBOSE:=true}
: ${DDOSSLEEP:=0.5}

$DEBUG && set -x
$TEST && git() { echo git "$@"; }

# functions ###############################################

usage() {
	n=gitsbackup.sh
	cat >&2 <<EOF
Usage: $n [OPTIONS] <backup dir> <config>...

Options:
     -i --info        - print all supported repositories syntax with info
     -q --quiet       - try to print as less as possible
     -n --setnice     - set niceness level as high as possible
     -u --user <user> - run script as specified user
                        (as that user may have ssh keys to some repos)
     -t --testrepos   - after syncing, test every repo with git ls-remote
     -h --help        - print this help and exit

Enviromental variables:
     TEST=false       - set to true to mask git cmd
     DEBUG=false      - set to true to enable debugging
     VERBOSE=true     - set to false to do the same as --quiet
     DDOSSLEEP=0.5    - argument passed to sleep(1) for pretecting against ddos

Backups all found repositories into backup dir, using:
'git clone --mirror and git remote update'.
Every backuped repository is stored inside a directory path
created from repository url.

Config:
	Every config argument is of a format:
		arg1:arg2[:arg3...]
	Config contains arguments to function getAllRepos defined inside the script.

Examples:
	$n /tmp/ github.com:\${UserName} gitlab.com:\${GITLAB_PRIVATE_TOKEN}

Written by Kamil Cukrowski (C) 2017. Under MIT License. Version 0.1.1
EOF
}

debug() { if $DEBUG; then     echo "$@"; fi; }
verbose() { if $VERBOSE; then echo "$@"; fi; }
warning() {                   echo "WARN:  ""$@" >&2; }
error() {                     echo "ERROR: ""$@" >&2; }
fatal() {                     echo "FATAL: ""$@" >&2; exit 1; }

if hash jq 2>/dev/null; then
	jq_get() { jq -r ".${2:-}[].$1"; }
else
	jq_get() { tr , '\n' | sed -ne '/"'"$1"'"[[:space:]]*:[[:space:]]*"/s/.*"'$1'"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p'; }
fi

backup_repos_do() {
	local url=$1 dir=$2
	verbose "backup_repo $url to $dir"
	if [ ! -d "$dir" ]; then
		git clone --mirror "$url" "$dir"
	fi
	git --git-dir="$dir" remote update
}

# main function
backup_repos() {
	# args: <outputdir> <git repo url>....
	local output="$1" url
	shift
	for url; do
		backup_repos_do "$url" "$output/$(sed -e 's;^\([a-z]*\)://;\1_;' <<<"$url")"
	done
}

# repos* subsystem - for downloading git repos url-s ####################################################

repos_supported=()
repos_supported_info=()

reposAddSupported() {
	repos_supported+=( "$1" )
	shift
	repos_supported_info+=( "$@" )
}

reposGet() { 
	local repo="$1" r
	shift
	for r in "${repos_supported[@]}"; do
		if [ "$r" == "$repo" ]; then
			debug 'found "$r" == "$repo" '
			reposGet_${repo} "$@"
			return 0
		fi
	done
	error "Passing repo $repo not found!"
	return 1
}

reposGetCheck() { 
	local repo="$1"
	shift
	for r in "${repos_supported[@]}"; do
		if [ "$r" == "$repo" ]; then
			return 0
		fi
	done
	return 1
}

reposPrintSupported() {
	local tmp1 tmp func args desc
	if [ "${#repos_supported[@]}" -eq 0 ]; then
		echo "No repos supported"
		return 1;
	fi
	tmp=$( paste <(printf "%s\n" "${repos_supported[@]}") <(printf "%s\n" "${repos_supported_info[@]}") )
	while read func args desc; do
		temp+="${func}:${args}#${desc}"$'\n'
	done <<<"$tmp"
	column -s'#' -t <<<"$temp"
}


# config #####################################################################

reposAddSupported github.com                "<user_name>    - backup repos for user"
reposGet_github.com() { 
	local username=$1
	curl -s "https://api.github.com/users/${username}/repos" | jq_get ssh_url; 
}

reposAddSupported gitlab.com_token          "<private-token> - backup repos using speicfied private-token from gitlab.com"
reposGet_gitlab.com_token() { 
	local private_token=$1
	curl -s --header "PRIVATE-TOKEN: $private_token" 'https://gitlab.com/api/v3/projects' | jq_get ssh_url_to_repo; 
}

reposAddSupported aur.archlinux.org_aurjson "<maintainer>   - backup repos for specified maintainer from aur.archlinux.org"
reposGet_aur.archlinux.org_aurjson() { 
	local maintainer=$1
	curl -s 'https://aur.archlinux.org/rpc/?v=5&type=search&by=maintainer&arg='$maintainer | \
		jq_get Name results | \
		sed 's;\(.*\);ssh://aur@aur.archlinux.org/\1.git;'
}

reposAddSupported aur.archlinux.org         "<maintainer>   - same as aur.archlinux.org_aurjson"
reposGet_aur.archlinux.org() { reposGet_aur.archlinux.org_aurjson "$@"; }

reposAddSupported aur.archlinux.org_html "<maintainer>   - backup repos for specified maintainer from aur.archlinux.org"
reposGet_aut.archlinux.org_html() {
	local maintainer=$1
	curl -s 'https://aur.archlinux.org/packages/?SeB=m&K='${maintainer} | \
		xmllint --html --xpath '//table[@class="results"]//tr/td[1]/a/@href' - | \
  		tr ' ' '\n' | sed -e '/^$/d' -e 's;^href="/packages/;;' -e 's;/"$;;' \
		sed 's;\(.*\);aur@aur.archlinux.org:/\1.git;'
}


# main #######################################################################

if [ $# -eq 0 ]; then usage; exit 1; fi
ARGS=$(getopt -o ithqnu: -l info,testrepos,help,quiet,setnice,user: -n 'gitsbackup.sh' -- "$@")
eval set -- "$ARGS"
testRepos=false;
while true; do
	case "$1" in
	-i | --info ) reposPrintSupported; exit 0; ;;
	-t | --testrepos ) testRepos=true; ;;
	-h | --help ) usage; exit 0; ;;
	-q | --quiet ) VERBOSE=false; ;;
	-n | --setnice) 
		ionice -c 3 -p $BASHPID >/dev/null # set Idle I/O scheduling priority
		renice -n 5 -p $BASHPID >/dev/null # set niceness level
		;;
	-u | --user)
		if [ "$(whoami)" != "$2" ]; then 
			name="$2"
			eval set -- "$ARGS" # restore all arguments
			sudo -E -u "$name" "$0" "$@"
			exit $?
		fi
		shift; ;; # we never get here
	--) shift; break; ;;
	*) fatal "Internal error in getopt"; exit 1; ;;
	esac
	shift
done

if [ "$#" -lt 2 ]; then usage; exit 1; fi;

# input arguments config
OUTPUTDIR="$1"
shift

# sanity check all repos if such exist
while IFS=: read -a args; do
	if ! reposGetCheck "${args[@]}"; then
		fatal "Error parsing \"${args[@]}\" argument. Check input arguments."
	fi
done <<<$(printf "%s\n" "$@")

# propagate repos list
repos=""
while IFS=: read -a args; do

	verbose "Repos from \"${args[@]}\":"

	if ! add=$(reposGet "${args[@]}"); then
		fatal "Error gettting repo from \"${args[@]}\". Check input arguments"
	fi
	if [ -z "$add" ]; then
		fatal "Getting repos from \"${args[@]}\" resulted in 0 repos."
	fi
	repos+="$add"$'\n'

	verbose "$add"

done <<<$(printf "%s\n" "$@")

verbose "Found $(wc -w <<<"$repos") git repos."

# shuffle repos list, to distrubute usage on repos evenly
repos=$(echo "$repos" | sort -R)

if $testRepos; then
	backup_repos_check() {
		echo
		echo "Checking repos validity:"
		for r; do
			echo -n "git ls-remote $r -- "
			if ! git ls-remote $r >/dev/null; then
				echo
				fatal "Internal error: $r is not a valid git repository"
			fi
			echo "OK"
			sleep $DDOSSLEEP # ddos protection
		done
	}
	backup_repos_do() {
		local url=$1 dir=$2
		echo "$url -> $dir"
	}

	echo
	echo "--> Testing repos:"
	echo "--> Legend: repo_url -> dir_where_repo_will_be_downloaded"
	backup_repos "$OUTPUTDIR" $repos
	backup_repos_check $repos
	echo "--> And all repos are ok"
else
	backup_repos "$OUTPUTDIR" $repos
fi


wait
echo
echo "Success!"


