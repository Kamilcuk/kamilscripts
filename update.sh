#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/.funcs.sh

log "Updating repository..."
git_remote_get-url | sed_remote_to_https | xargs -t git remote set-url origin
runlog git pull --rebase
git_remote_get-url | sed_remote_to_ssh | xargs -t git remote set-url origin

log "Updating submodules..."
cur=$(./gitmodules_links_change.sh detect)
runlog ./gitmodules_links_change.sh https
runlog ./update_submodules.sh
runlog ./gitmodules_links_change.sh "$cur"

f=~/.config/kamilscripts/kamilscripts
if [[ -e "$f" && -L "$f" ]]; then
	log "Stowing kamilscripts..."
	runlog bin/,kamilscripts_stow.sh i --ok
fi


