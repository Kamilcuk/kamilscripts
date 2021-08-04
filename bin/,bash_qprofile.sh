#!/bin/bash

# functions ########################################

QPROF_name=",bash_qprofile.sh"

QPROF_usage() {
	cat <<EOF
Usage:   source ${QPROF_name} [MODE]

Modes:
   1start
   1stop
   1stop_auto
EOF
}

QPROF_fatal() {
	QPROF_usage
	echo
	echo ",bash_startup_speed.sh:" "ERROR:" "$@"
	QPROF_end
}

QPROF_timestamp() {
	python -u -c "$(cat <<-EOF
			import string
			printable = string.ascii_letters + string.digits + string.punctuation + ' '
			def hex_escape(s):
			  return ''.join(c if c in printable else r'\x{0:02x}'.format(ord(c)) for c in s)

			import os, sys, datetime;
			out = open(sys.argv[1], "a")
			out.write( "{}\n".format(os.getpid()) )
			out.flush()

			last = datetime.datetime.now().timestamp()
			for i in sys.stdin:
			  now = datetime.datetime.now().timestamp()
			  if (len(i) > 0 and i[-1] == "\n"):
			    i = i[:-1]
			  out.write( "{:.9f} {:}\n".format(now - last, hex_escape(i)) )
			  last = now
			  out.flush()
		EOF
	)" "$@"
}

# shellcheck disable=2046
QPROF_end() {
	unset -f $(compgen -A function | grep '^QPROF_')
	unset QPROF_is_sourced QPROF_name
}

# Main #################################################

if (return 0 2>/dev/null); then QPROF_is_sourced=1; else QPROF_is_sourced=0; fi
export QPROF_OUT=${QPROF_OUT:-/tmp/sample-time.$$.log}

# shellcheck disable=1090
case "${1:-}" in
test)
	if ((QPROF_is_sourced)); then
		QPROF_fatal "Test has to be run"
		exit
	fi
	echo 123 | QPROF_timestamp "/dev/stdout"
	echo -----------------------
	source "$0" 1start
	for ((i=3;i--;)); do sleep ".0$i"; done
	for i in 3 2 1; do sleep ".0$i"; done
	source "$0" 1stop_auto
	exit
	;;
esac

if ((!QPROF_is_sourced)); then
	QPROF_fatal "This script has to be sourced"
	exit
fi

case "$1" in

# method 1
1start)
	echo "Logging to QPROF_OUT=$QPROF_OUT"
	exec 3>&2 2> >(QPROF_timestamp "$QPROF_OUT")
	set -x
	;;
1stop*)
	set +x
	exec 2>&3 3>&-
	# shellcheck disable=2016
	timeout 2 bash -c 'while [[ -z "$(head -n1 "$1")" ]]; do sleep 0.01; done' _ "$QPROF_OUT"
	wait "$(head -n1 "$QPROF_OUT")" 2>/dev/null >/dev/null ||:
	;;& # test 1stop_auto too!
1stop_auto)
	echo
	echo ",bash_startup_speed: ---- $QPROF_OUT:"
	tail -n+2 "$QPROF_OUT" | nl -w3 -s' '
	echo
	echo ",bash_startup_speed: ---- max${2:-20}: "
	tail -n+2 "$QPROF_OUT" | nl -w3 -s' ' | LC_ALL=C sort -rnk2 | head -n"${2:-20}"
	echo ",bash_startup_speed: -----"
	echo
	rm "$QPROF_OUT"
	;;

# method2
# who cares - method1 is just enough

*)
	QPROF_fatal "Invalid command $1"
	return 1;
	;;
esac

return
exit

# from https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
# written by F. Hauri
#
# Elap bash source file Version 2
# Based on /proc/timer_list only
#
# Usage:
#   source elap.bash [init|trap|trap2]
#
# Bunch of functions without test for ensuring minimum time consumption
#
#

# Useable functions
elap()          { elapGetNow;elapCalc;elapShow "$@";elapCnt;}
elapTotal()     { elapGetNow;elapCalc2;elapShowTotal "$@";}
elapBoth()      { elapGetNow;elapCalc;elapCalc2;elapShowBoth "$@";elapCnt;}
elapReset()     { elapGetNow;elapCnt;}
elapResetTotal(){ elapGetNow;elapCntTotal;}
elapResetBoth() { elapGetNow;elapCntBoth;}

# Semi internal functions
elapShow()      { echo -e "$_elap $*";}
elapShowTotal() { echo -e "$_elap2 $*";}
elapShowBoth()  { echo -e "$_elap $_elap2 $*";}

# Internal functions
elapCnt()       { _eLast=$_eNow ;}
elapCntTotal()  { _eLast2=$_eNow;}
elapCntBoth()   { _eLast=$_eNow ; _eLast2=$_eNow;}
elapGetNow()    {
	# shellcheck disable=2162
    read -dk -a_eNow </proc/timer_list;
    _eNow=${_eNow[8]}
}
elapCalc() {
    _elap=000000000$((_eNow - _eLast))
    printf -v _elap "%16.9f" \
	"${_elap:0:${#_elap}-9}"."${_elap:${#_elap}-9}"
}
elapCalc2() {
    _elap2=000000000$((_eNow - _eLast2))
    printf -v _elap2 "%16.9f" \
	"${_elap2:0:${#_elap2}-9}"."${_elap2:${#_elap2}-9}"
}

export _eNow _eLast _eLast2 _elap _elap2

[ "$1" == "trap2" ] || [ "$1" == "trap" ] || [ "$1" == "init" ] && elapResetBoth
if [ "$1" == "trap" ] ;then
    if [ "${-/*i*/1}" == "1" ] ;then
	trap '[ "${BASH_COMMAND%elap*}" == "$BASH_COMMAND" ] && {
	     elapReset;BASH_LAST=$BASH_COMMAND; }' debug
	PROMPT_COMMAND='elap $BASH_LAST'
    else
	export BASH_LAST=Starting
	trap 'trap -- debug;elapTotal EXIT;exit 0' 0
	trap 'elap $BASH_LAST;BASH_LAST=$BASH_COMMAND' debug
    fi
else
    if [ "$1" == "trap2" ] ;then
	if [ "${-/*i*/1}" == "1" ] ;then
	    trap '[ "${BASH_COMMAND%elap*}" == "$BASH_COMMAND" ] && {
		 elapReset;BASH_LAST=$BASH_COMMAND; }' debug
	    PROMPT_COMMAND='elapBoth $BASH_LAST'
	else
	    export BASH_LAST=Starting
	    trap 'trap -- debug;elapBoth EXIT;exit 0' 0
	    trap 'elapBoth $BASH_LAST;BASH_LAST=$BASH_COMMAND' debug
	fi
    fi
fi

