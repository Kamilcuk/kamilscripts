#!/bin/bash
set -xeuo pipefail
git add -A
git commit -m "Updates from $HOSTNAME"
git push

