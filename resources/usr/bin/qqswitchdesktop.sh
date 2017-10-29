#!/bin/bash


num=$(xdotool get_num_desktops)
act=$(xdotool get_desktop)
prev=$[$act-1]
next=$[$act+1]
if test $prev -eq -1; then
	prev=$[$num-1]
fi
if test $next -eq $num; then
	next=0
fi

if test -z $1; then
	exit 0
fi

case $1 in
'+')
	xdotool set_desktop $next
;;
'-')
	xdotool set_desktop $prev
;;
*)
	echo FUCK YOU!
esac

