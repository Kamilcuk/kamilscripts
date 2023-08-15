#!/bin/bash
set -xeuo pipefail
git pull --rebase --autostash
git add -A
git commit -m "$HOSTNAME: Updates"
git push

