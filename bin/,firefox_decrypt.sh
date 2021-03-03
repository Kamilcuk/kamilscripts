#!/bin/bash
set -euo pipefail
c=~/.cache/firefox_decrypt.py
curl -sS -C - -o "$c" https://raw.githubusercontent.com/unode/firefox_decrypt/master/firefox_decrypt.py
chmod +x "$c"
"$c" "$@"

