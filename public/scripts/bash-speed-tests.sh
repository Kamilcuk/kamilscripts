#!/bin/bash

octave_eval() {
	( set -x; 
	octave -q -f -W --eval "$*"
	)
}

rtest_values=(rtest_cmd rtest_task_clock rtest_task_clock_dev rtest_time_elapsed rtest_time_elapsed_dev)
for i in ${rtest_values[@]}; do
	eval ${i}=\(\)
done
rtest() {
	howmanytimes=$1
	shift
	{
		output=$(cat)
		rtest_cmd+=("$*")
		rtest_task_clock+=("$(echo "$output" | grep task-clock | awk '{print $1}')")
		rtest_task_clock_dev+=("$(
			temp=$(echo "$output" | grep task-clock | grep "+-")
			if [ -z "$temp" ]; then echo "0"; else
				echo $(echo "$temp" | sed 's/.*+-[[:space:]]*\([0-9\.]*\)*%.*/\1/')
			fi
		)")
		rtest_time_elapsed+=("$(echo "$output" | grep "seconds time elapsed" | awk '{print $1}')")
		rtest_time_elapsed_dev+=("$(echo "$output" | grep "seconds time elapsed" | awk '{print $7}' | sed 's/%//')")
	} < <( sudo ionice -c 1 -n 7 nice -n -20 perf stat ${howmanytimes:+-r $howmanytimes} "$@" 2>&1 | tee >(cat >&2) )
	export rtest_cmd rtest_task_clock
}
rtest_stat() {
	for i in $(seq 1 $((${#rtest_cmd[@]}-1))); do
		for j in ${rtest_values[@]}; do
			eval echo -n "\"\\\"\${$j[$i]//\\\"/}\\\" \""
		done
		echo
	done | \
	tee >(cat >&2) | \
		octave_eval '
	v = textscan(fopen("/dev/stdin"), "'"$(for i in ${rtest_values[@]};do echo -n "%q ";done | sed 's/ $//')"'");
	[~,idx] = sort(str2double(cell2mat(v(:,2))));
	pkg load dataframe
	dataframe([
	'"$(for i in ${rtest_values[@]};do echo -n "\"${i/#rtest_/}\","; done|sed 's/,$//')"';
	'"$(for i in ${rtest_values[@]};do echo -n "\"0\","; done|sed 's/,$//')"';
	cell2mat(v)(idx,:)])
	'
}

bashrun="bash --norc -c "
sectionname=""
section() {
	sectionname="$*"
	echo "- =========     $sectionname ========= "
}
endsection() {
	echo "- ========= EOF $sectionname ========= "
}

case "$1" in
0)
	section="test script"
	tests_num=2
	tests=(
		"sleep 0.001"
		"sleep 0.01"
		"sleep 0.0001"
		"echo | cat >/dev/null"
		"echo 'a' \"b\" \"'c\""
	)
	;;
1)
	section="read variables"
	tests=( 
		"read a b c <<<'a b c'"
		"read -r a b c <<<'a b c'"
	       	"read a b c < <(echo 'a b c')"
		"IFS=' ' read a b c < <(echo 'a b c')"
	)
	;;
*)
	echo "Unknown argument. Should be [1]."
	exit 1
	;;
esac


section $section
for i in "${tests[@]}"; do
	rtest ${tests_num:-50} $bashrun "${i}"
done
echo
rtest_stat
echo
endsection

