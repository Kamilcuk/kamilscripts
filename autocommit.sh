#!/bin/bash
set -euo pipefail
git fetch
branch=$(git rev-parse --abbrev-ref HEAD)
git merge-base --is-ancestor origin/master master

