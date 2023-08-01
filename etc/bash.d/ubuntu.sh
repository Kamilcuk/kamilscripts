#!/bin/sh

if [ -r /etc/os-release ] && grep -i ubuntu /etc/os-release; then
	alias p=',apt p'
	alias pn=',apt pn'
	alias pupdate=',apt pupdate'
fi
