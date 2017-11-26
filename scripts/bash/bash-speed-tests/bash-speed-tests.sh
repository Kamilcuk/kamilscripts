#!/bin/bash -eu
# Witten by Kamil Cukrowski 2017
#
########################################### funtions ############################

octave_eval() {
	( $VERBOSE && set -x || true;
	octave -q -f -W --eval "$*"
	)
}

rtest_stat_files=()
rtest() {
	declare -g rtest_stat_files

	rtest_showstdout=${rtest_showstdout:-false}
	rtest_showstderr=${rtest_showstderr:-true}
	rtest_useperf=${rtest_useperf:-true}
	rtest_useeval=${rtest_useeval:-true}

	local cmd perfargs
	perfargs=" ${rtest_repeat:+-r $rtest_repeat} "
	if [ -z "${cmd:-}"]; then
		$rtest_useperf && cmd="eval " || true
		if $rtest_useperf; then
			cmd="$cmd sudo ionice -c 1 -n 7 nice -n -20	perf stat ${perfargs}"
		fi
	fi

	local fstderr fstdout
	fstderr=$(mktemp -p $tmpdir)
	fstdout=$(mktemp -p $tmpdir)

	exec 3> >( { if $rtest_showstdout; then tee >(cat >&2); else cat; fi; } >$fstdout )
	exec 4> >( { if $rtest_showstderr; then tee >(cat >&2); else cat; fi; } >$fstderr )

	(
		$VERBOSE && set -x || true
		$cmd "$@" >&3 2>&4
		echo "$@" >&4
	)

	exec 3>&-
	exec 4>&-

	rtest_stat_files+=("$fstderr")

	export rtest_stat_files
}

rtest_stat() {
	declare -g rtest_stat_files
	local rtest_values i
	# init values
	rtest_values=(rtest_cmd rtest_task_clock rtest_tc_dev rtest_time_elapsed rtest_te_dev)
	for i in ${rtest_values[@]}; do
		eval local $i=\(\)
	done
	# read values from rtest_stat_files - global variable!
	for i in ${rtest_stat_files[@]}; do
		if [ ! -s "$i" ]; then
			echo "ERROR: ! -s $i "
			continue;
		fi
		val=$(tail -n1 $i)
		val=${val/#$BASHRUN/}
		rtest_cmd+=("$val")

		read val _ _ _ _ _ _ _ _ std _ < <(grep "task-clock" $i)
		if [ -z "$val" ]; then val=0; fi
		rtest_task_clock+=("$val")
		if [ -z "$std" ]; then std=0; fi
		rtest_tc_dev+=("${std/%%/}")

		read val _ _ _ _ _ std _ < <(grep "seconds time elapsed" $i)
		if [ -z "$val" ]; then val=0; fi
		rtest_time_elapsed+=("$val")
		if [ -z "$std" ]; then std=0; fi
		rtest_te_dev+=("${std/%%/}")
	done
	# do octave magic
	for i in $(seq 0 $((${#rtest_cmd[@]}-1))); do
		for j in ${rtest_values[@]}; do
			eval echo -n "\"\\\"\${$j[$i]//\\\"/}\\\" \""
		done
		echo
	done | \
	( $VERBOSE && { tee >(cat >&2); } || cat; ) | \
		octave_eval '
	v = textscan(fopen("/dev/stdin"), "'"$(for i in ${rtest_values[@]};do echo -n "%q ";done | sed 's/ $//')"'");
	[~,idx] = sort(str2double(cell2mat(v(:,2))));
	pkg load dataframe
	dataframe([
	'"$(for i in ${rtest_values[@]};do echo -n "\"${i/#rtest_/}\","; done|sed 's/,$//')"';
	'"$(for i in ${rtest_values[@]};do echo -n "\"0\","; done|sed 's/,$//')"';
	cell2mat(v)(idx,:)])
	' | ( $VERBOSE && cat || awk 'NR != 1 && NR != 3'; )
}

####################################################### other functions #########################3

error() { echo "ERROR: $@" >&2; }
verbose() { if $VERBOSE; then echo "$@"; fi; }

sectionname=""
section() {
	sectionname="$*"
	echo "-=     $sectionname"
}
endsection() {
	echo "-= EOF $sectionname"
}

testsrun() {
	section "\"$1\" -- test_count=$# rtest_repeat=$rtest_repeat"
	if [ -n "$(type -t testsprepare)" ] && [ "$(type -t testsprepare)" = function ]; then
		testsprepare
	fi
	shift
	for i in "$@"; do
		if [ -n "$BASHRUN" ]; then
			rtest $BASHRUN \'"${i//\'/\"\'\"}"\'
		else
			rtest "${i}"
		fi
		verbose "run $i"
	done
	if [ -n "${testsaddoutput:-}" ]; then
		verbose
		echo "${testsaddoutput}"
	fi
	verbose
	rtest_stat
	verbose
	$VERBOSE && endsection || true
}

usage() {
	cat <<EOF
USAGE:
    $0 [OPTIONS] <test number> [<test argument> ...]

OPTIONS:
    -r <n>                 - repeat tests <n> times (default: 2)
    -s [true|false]        - show or don't show stdout of commands (default: false)
    -e [true|false]        - show or don't show stderr of commands (default: true)
    -t                     - repeat 1 time, show test stdout, for testing
    -q                     - quiet, less verbose output
    -x                     - add -x flag to BASHRUN
    -D                     - debug mode (set -x)

Examples:
    $0 0
    $0 

Written by: Kamil Cukrowski (c) 2017. Licensed under MIT License.
EOF
}

#########################################3 main ######################################

if [ $# -eq 0 ]; then usage; exit 1; fi
# getopts
BASHRUN=${BASHRUN:-"bash --norc -c "}
VERBOSE=true DEBUG=${DEBUG:-false} MODE=-1 
rtest_repeat=2 rtest_showstdout=false rtest_showstderr=true
bashrun_set_x=false;
args=$(getopt --name "$0" -o r:s:e:tqxD -- "$@")
eval set -- "$args"
while true; do
	case "${1/#-/}" in
		r) rtest_repeat=${2}; shift; ;;
        s) rtest_showstdout=${2}; shift; ;;
		e) rtest_showstderr=${2}; shift; ;;
		t) rtest_showstdout=true; rtest_showstderr=true; rtest_repeat=1; ;;
		q) rtest_showstderr=false; VERBOSE=false; ;;
		x) bashrun_set_x=true; ;;
		D) set -x; echo "args=$args"; DEBUG=true; ;;
		-) shift; break; ;;
        *) echo "ERROR in parsing arguments: ${1}"; usage; exit -1; ;;
	esac
	shift
done
mode="$1";
shift

# input sanity
if $DEBUG; then set -x; fi
if $bashrun_set_x; then
	BASHRUN="bash --norc -xc "
fi
if [ -z "$mode" ]; then
	error "No test number given"
	usage;
	exit 1;
fi

############## install traps create tempfiles
{
	tmpdir=$(mktemp -d -p /tmp r.XXX)
	tmpfile=$tmpdir/t1
	tmpfile2=$tmpdir/t2
	tmpfile3=$tmpdir/t3
	pushd $tmpdir >/dev/null # into $tmpdir
	trapExit() {
		local r=$?;
		popd >/dev/null # out of $tmpdir
		if [ $r -ne 0 ]; then
			echo "ERROR: Last command returned: $r" >&2
		fi
		rm -rf $tmpdir
	}
	trap 'trapExit' EXIT
}

############### main switch 

mode_switch_prepare_tests_desc() {
	declare -g tests_desc
	tests_desc=()
	case "$mode" in
	0)
		b1() { echo "a b c"; }
		b2() { echo 'a' \"b\" \"'c'\"; }
		declare -f b1 b2 >$tmpfile
		tests_desc=(
			"test script"
			"sleep 0.001"
			"sleep 0.01"
			"sleep 0.0001"
			"echo | cat >/dev/null"
			"echo 'a' \"b\" \"'c'\""
			'a() { echo "a b c"; }; a a b c;'
			". $tmpfile; b1;"
			". $tmpfile; b2;"
		)
		;;
	1)
		tests_desc=(
			"read variables"
			"read a b c <<<'a b c'"
			"read -r a b c <<<'a b c'"
			"read a b c < <(echo 'a b c')"
			"IFS=' ' read a b c < <(echo 'a b c')"
		)
		;;
	2)
		y=$(date +%Y)
		m=$(date +%m)
		d=$(date +%d)
		BASHRUN=
		tests_desc=(
			"date parsing"
			"date --date=\"$y-$m-$d\""
			"date -d     \"$y/$m/$d\""
			"date --date=\"$y-$m-$d 00:00:00\""
		)
		;;
	3)
		tests_desc=(
			"bash local or not local"
			'a(){ local a;a=1;};a;'
			'a(){ a=1;};a;'
			'a(){ : empty;a=1;};a;'
		)
		;;
	4)
		l=(a b c d e f g h i j k l m n o p r s t u v x y z);
		l=( $(for i in a b c d e f g h i j l m; do echo ${l[@]/#/$i}; done;) )
		a="+"
		lazy() { 
			case "$#" in
			1) v=1; for i in "${l[@]}";do eval echo -n "\"$1\""; v=$((v+1)); done; ;;
			2) v=1; for i in "${l[@]}";do eval echo -n "\"${1}\""; eval echo -n "\"${2}\""; v=$((v+1)); done | sed 's/'"${2}$"'//'; ;; 
			*) echo "ERRROR" >&2; exit 1; ;;
			esac
		}
		tests_desc=(
			"bash addition"
			"$( lazy '$i=$v ' )z=\$(($( lazy '$i'   "$a")))"
			"$( lazy '$i=$v;' )z=\$(($( lazy '$i'   "$a")))"
			"$( lazy '$i=$v ' )z=\$[$(  lazy '\$$i' "$a")]"
			"$( lazy '$i=$v ' )z=\$(($( lazy '\$$i' "$a")))"
		)
		#set -x; echo ${tests[@]}; exit;
		;;
	5)
		journalctl -n ${2:-20000} >"$tmpfile"
		tests_desc=(
			"first line in file"
			"head -1 $tmpfile"
			"sed -n 1p $tmpfile"
			"sed -n '1{p;q}' $tmpfile"
			"read line < $tmpfile && echo \$line"
		)
		;;
	6)
		pre=${3:-123456}
		suf=${4:-167890}
		journalctl -n ${2:-20000} 2>/dev/null | sed -e "s/^/${pre}/" -e "s/$/${suf}/" >"$tmpfile"
		tests_desc=(
			"filter suffix and prefix"
			"cat $tmpfile | sed -e 's/^$pre//' -e 's/$suf$//'"
			"sed -e 's/^$pre//' -e 's/$suf$//' $tmpfile"
			#"while read -r a; do a=\${a##$pre}; echo \"\${a%%$suf}\"; done <$tmpfile" # najwolniejsze
	#		"IFS='
	#' GLOBIGNORE='*' command eval \"a=(\$(<$tmpfile))\"; a=\"\${a[@]##$pre}\"; printf \"%s\n\" \"\${a[@]%%$suf}\";"
	#		"readarray a <$tmpfile;              a=\"\${a[@]##$pre}\"; printf \"%s\n\" \"\${a[@]%%$suf
	#}\";"
		)
		;;
	7)
		len=${1:-15}
		journalctl -n $len 2>/dev/null >$tmpfile
		startdate=$(head -n $((len*33/100)) $tmpfile | tail -n 1 | sed 's/leonidas.*/leonidas/')
		stopdate=$( head -n $((len*66/100)) $tmpfile | tail -n 1 | sed 's/leonidas.*/leonidas/')
		testsprepare() {
			echo "len=$(wc -l <$tmpfile)"
			echo "startdate=$startdate"
			echo "stopdate =$stopdate"
		}
		f_bash() {
			{
				while read line; do 
					if [[ $line =~ ^$startdate ]]; then
						break;
					fi
				done
				while read line; do
					echo "$line";
					if [[ $line =~ ^$stopdate ]]; then
						break;
					fi
				done 
			} <$1
		}
		f_sed() {
			sed "
			/^$startdate/{
				:a;
				p;
				n;
				/$stopdate/{
					q 0;
				}
				ba;
			}" "$1"
		}
		f_sed2() {
			sed "/^$startdate/{:a;p;n;/$stopdate/q 0;ba;}" "$1"
		}
		declare -f f_bash f_sed f_sed2 > $tmpfile2
		declare -p startdate stopdate >> $tmpfile2
		tests_desc=(
			"test bash awk sed lines between patterns"
			". $tmpfile2; f_bash $tmpfile >/dev/null;"
			". $tmpfile2; f_sed  $tmpfile >/dev/null;"
			". $tmpfile2; f_sed2 $tmpfile >/dev/null;"
		)
		;;
	8)
		f
	*) 
		echo "Unknown mode."; usage; exit 1; ;;
	esac
}

mode_switch_prepare_tests_desc "$@"
testsaddoutput="${testsaddoutput:-}" testsrun "${tests_desc[@]}"

