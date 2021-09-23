#!/bin/bash

echo Welcome to auto ssh no password program. HF.
echo
if [ ! -e ~/.ssh/id_rsa ]; then
	echo
	echo Och! You have no ~/.ssh/id_rsa file. No local rsa key pair.
	echo No worries. We are goin to generate them.
	echo
	ssh-keygen -t rsa
fi
echo
echo Ok.
echo
echo You need to log through ssh to given host.
echo Write your password:
echo
echo ssh "$*"
set -x
< ~/.ssh/id_rsa.pub ssh "$@" "
set -x;
if ! [ -d ~/.ssh ]; then 
	mkdir -p ~/.ssh ;
	cat >> ~/.ssh/authorized_keys ;
else
	str=\"\$(cat)\" ;
	str2=\"\$(echo \${str}|awk '{print \$3}')\" ;
	sed -i.bak '/'\"\${str2}\"'/d' ~/.ssh/authorized_keys ;
	echo \"\${str}\" >> ~/.ssh/authorized_keys ;

fi;
set +x;
"
set +x
echo
echo 'Congrats!. You'\''ve done it!'
echo

