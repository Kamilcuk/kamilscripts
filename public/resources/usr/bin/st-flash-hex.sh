#!/bin/sh
exec st-flash --format ihex write "$@"
