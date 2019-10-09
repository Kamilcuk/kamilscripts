#!/bin/bash
set -xeuo pipefail
if hash yay 2>/dev/null; then
	ionice nice yay -Suy --nocofirm
else
	ionice nice pacman -Suy --noconfirm
fi

