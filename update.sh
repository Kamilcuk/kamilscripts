#!/bin/bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
set -x
cur=$(./gitmodules_links_change.sh detect)
./gitmodules_links_change.sh https
./update_submodules.sh
./gitmodules_links_change.sh "$cur"

