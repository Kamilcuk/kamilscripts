#!/bin/sh
set -x
find . -print0 | xargs -0 -P$(nproc) -n1 sh -c 'iconv -f utf-8 -t utf-16 <<<"$1" 2>/dev/null 1>&2 || echo "$1"' _

