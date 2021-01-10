#!/bin/bash
set -euo pipefail
if git submodule --help | grep -q update | grep -q -- --remote; then
	set -x
	git submodule update --remote --merge --recursive
else
	set -x
	git submodule update --merge --recursive
fi




