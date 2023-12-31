#!/bin/sh
if [ -z "${KCDIR:-}" ]; then
	echo "awk/activate.sh: KCDIR is not set" >&2
	return 2
	exit 2
fi
case ":${AWKPATH:-}:" in
*:"$KCDIR/awk":*) ;;
*) export AWKPATH="$KCDIR/awk${AWKPATH:+:$AWKPATH}" ;;
esac
