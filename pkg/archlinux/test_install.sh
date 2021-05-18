#!/bin/bash
set -xueo pipefail
cd "$(dirname "$0")"
./build.sh
,makepkg-root -i

