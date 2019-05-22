#!/bin/bash
set -xeuo pipefail
docker run -v $(git rev-parse --show-toplevel):/repo:ro \
	$(<<<archlinux/base :) antergos/makepkg sh -c '
cp -a /repo /work && 
cd /work &&
pkg/archlinux/docker_build.sh /output
'

