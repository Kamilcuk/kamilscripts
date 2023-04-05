#!/bin/bash
set -xeuo pipefail
git add -A
git commit -m "$HOSTNAME: Updates"
git push

