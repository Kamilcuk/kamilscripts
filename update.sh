#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/.funcs.sh

log "Updating repository..."
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

log "Updating submodules..."
runlog ./submodules_update.sh

f=~/.kamilscripts
if [[ -e "$f" && -L "$f" ]]; then
	log "Stowing kamilscripts..."
	runlog ./bin/,kamilscripts.sh u -k
fi


