#!/bin/sh
if [ ! -d /etc/rc-sleep ]; then exit; fi
for i in /etc/rc-sleep/*; do if [ -x "$i" ]; then "$i" "$@"; fi; done;

