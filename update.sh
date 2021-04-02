#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/.funcs.sh

log "Updating repository..."
git_remote_get-url | sed_remote_to_https | xargs -t git remote set-url origin
autostash=$(git --version | awk '{exit !(0+$3>2.6)}' && printf "%s\n" --autostash ||:)
runlog git pull --rebase $autostash
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


