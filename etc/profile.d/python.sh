#!/usr/bin/sh

if false && [ -e "$KCDIR" ] && [ -r "$KCDIR/python" ]; then
	case ":$PYTHONPATH:" in
	*":$KCDIR/python:"*) ;;
	*) export PYTHONPATH="$KCDIR/python${PYTHONPATH:+:$PYTHONPATH}"
	esac
fi
if [ "${UID:-0}" -ne 0 ]; then
	export PIP_BREAK_SYSTEM_PACKAGES=1
else
	if [ -e "${PIP_BREAK_SYSTEM_PACKAGES:-}" ]; then
		unset PIP_BREAK_SYSTEM_PACKAGES
	fi
fi

