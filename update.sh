#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/.funcs.sh

log "Updating repository..."
git_remote_get-url | sed_remote_to_https | xargs -t git remote set-url origin
if git_autostash_supported; then
	runlog git pull --rebase  --autostash
else
	if [[ -n "$(git status --porcelain)" ]]; then
		runlog git stash --include-untracked
		runlog git pull --rebase
		runlog git stash apply
	else
		runlog git pull --rebase
	fi
fi
git_remote_get-url | sed_remote_to_ssh | xargs -t git remote set-url origin

log "Updating submodules..."
runlog ./gitmodules_links_change.sh https
runlog ./submodules_update.sh
runlog ./gitmodules_links_change.sh git

f=~/.config/kamilscripts/kamilscripts
if [[ -e "$f" && -L "$f" ]]; then
	log "Stowing kamilscripts..."
	runlog bin/,kamilscripts_stow.sh u --ok
fi


