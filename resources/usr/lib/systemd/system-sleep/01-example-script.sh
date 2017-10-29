#!/bin/bash
# file: /usr/lib/systemd/system-sleep/01-example-script
# doc:  https://www.freedesktop.org/software/systemd/man/systemd-suspend.service.html
case "$1" in
"pre")
	;;
"post")
	;;
esac
case "$1 $2" in
"pre suspend")
	;;
"post suspend")
	;;
"pre hibernate")
	;;
"post hibernate")
	;;
"pre hybrid-sleep")
	;;
"post hybrid-sleep")
	;;
esac
