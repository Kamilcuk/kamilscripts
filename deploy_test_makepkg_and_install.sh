#!/bin/bash
set -euo pipefail
set -x
host=${1}
rsync -r -a $(pwd)/ $host:/tmp/kamil-scripts.temp/
ssh $host /bin/bash -c '"set -euo pipefail; set -x; 
	cd /tmp/kamil-scripts.temp/
	echo Compiling, installing....
	./test_makepkg_and_install.sh
	echo DONE
	echo Cleanup left in /tmp/kamil-scripts.temp
"'


