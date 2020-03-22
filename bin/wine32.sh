#!/bin/bash
exec env WINEPREFIX="$HOME"/.wine32/ LC_ALL=C WINEARCH=win32 wine "$@"

