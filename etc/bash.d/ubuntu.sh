#!/bin/sh

if [ -r /etc/os-release ] && grep -qi ubuntu /etc/os-release; then
	alias p=',apt p'
	alias pn=',apt pn'
	alias pupdate=',apt pupdate'
fi
