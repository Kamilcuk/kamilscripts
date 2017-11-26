#!/bin/bash

host=${1}
ssh $host /bin/bash c 'set -euo pipefail; set -x; 
	pacman --noconfirm -S git
	cd /tmp
	echo Git cloning...
	git clone git@github.com:Kamilcuk/kamil-scripts.git kamil-scripts
	cd kamil-scripts
	echo Compiling, installing....
	./makepkg_and_install.sh
	echo DONE
	echo Cleanup left in /tmp/kamil-scripts
'


