#!/bin/bash
exec env WINEPREFIX=/home/users/kamil/.wine32/ LC_ALL=C WINEARCH=win32 wine "$@"

