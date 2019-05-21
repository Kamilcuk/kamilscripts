#!/bin/bash
# Kamil Cukrowski
set -euo pipefail

TEST=${TEST:-false}
DEBUG=${DEBUG:-false}

# Functions #########################################################

usage() {
	cat <<EOF
Usage: 
	qqrdiffbackup.sh <list> <remove-older-than> <destination> [<rdiff-backup option>...]

Script is a wrapper around rdiff-backup.
It runs rdiff-backup twice:
  First, to do incremental backup based on list of sources to backup
  Second, to remove older backups then specified date.

Arguments:
  list:
    First argument is a list of destinations to backup and is the most important
    The list is passed to rdiff-backup by pipe, with ' --include-globbing-filelist-stdin --exclude "**" '
    Empty lines are removed!
  remove-older-than:
    Argument is passed to --remove-older-than to rdiff-backup
  dest:
    Destination is passed as the last rdiff-backup argument
  rdiff-backup options:
    All options are passed to rdiff backup

Environment:
  TEST=true
    Does not run ridff-backup, only prints out, good for debugging.
  DEBUG=true
    does nothing

Written by Kamil Cukrowski. Under beerware 
EOF
}

rdiff-backup() {
	local stdin=""
	if [ ! -t 0 ]; then stdin=$(cat); fi
	echo "+ echo '$stdin' | rdiff-backup" "$@"
	if ! $TEST; then
		echo "$stdin" | command rdiff-backup "$@"
	fi
}

# Main ##############################################################

if [ $# -lt 3 ]; then
	usage;
	exit 1;
fi

# Read input
list=$1
remove_older_than=$2
destination=$3
shift 3
args=( "$@" )

# Check input
list=$( echo "$list" | sed -e 's/^[[:space:]]*//' -e '/^$/d' ) # remove leading space and empty lines
if echo "$list" | grep -q -x '/'; then
	echo "ERROR: list wants to backup whole filesystem." >&2
	exit 1
fi 

args=( -v3 --terminal-verbosity 2 --print-statistics "${args[@]}" )

# Work

if [ -n "$list" ]; then
	echo "$list" | \
	rdiff-backup "${args[@]}" --include-globbing-filelist-stdin --exclude "**" / "$destination"
fi
if [ -n "$remove_older_than" ]; then
	rdiff-backup "${args[@]}" --remove-older-than "$remove_older_than" --force "$destination"
fi

