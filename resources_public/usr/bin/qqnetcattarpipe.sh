#!/bin/bash

usage() {
        echo "$0 [-s] out   <folder/pliki> <host> <port>"
	echo "$0 [-s] in    <folder fo wywalenia> <port>"
	echo "$0 [-s] inraw <plik do wywalenia>   <port>"
        echo "This program makes netcat tar pipe."
	echo " -s = nc is silent."
        exit 0
}
test $# -lt 1 && usage
OPTS='-v'
if test ${1} == '-s'; then
	OPTS='';
	shift;
fi

case ${1} in
"out")
	test $# -lt 4 && usage
	echo "+ tar ${OPTS} -cf - $(readlink -f ${2}) | nc ${OPTS} -4 ${3} ${4}"
	tar ${OPTS} -cf - $(readlink -f ${2}) | nc ${OPTS} -4 ${3} ${4}
	;;
"inraw")
        test $# -lt 2 && usage
	echo "+ nc -4 ${OPTS} -l ${3} > $(readlink -f ${2})"
        nc -4 ${OPTS} -l ${3} > "$(readlink -f ${2})"
        ;;

"in")
	test $# -lt 2 && usage
	echo "+ nc -4 ${OPTS} -l ${3} | tar ${OPTS} -xpf - -C $(readlink -f ${2})"
	nc -4 ${OPTS} -l ${3} | tar ${OPTS} -xpf - -C "$(readlink -f ${2})"
	;;
*) usage ;;
esac



