#!/usr/bin/sh

case ":$KCDIR/python:" in
:"$PYTHONPATH":) ;;
*) export PYTHONPATH="$KCDIR/python${PYTHONPATH:+:$PYTHONPATH}"
esac
