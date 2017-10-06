#!/bin/bash
exec st-flash --format binary write "$1" "${2:-0x8000000}"
