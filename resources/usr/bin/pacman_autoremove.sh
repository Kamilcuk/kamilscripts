#!/bin/bash
set -euo pipefail
tmp=$(pacman --query --deps --unrequired --quiet)
pacman --remove $tmp "$@"

