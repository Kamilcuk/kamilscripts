#!/bin/bash
# shellcheck disable=2086,2206,2162,2016,2207,2034,2059,2046
# part of qqsplitscreenpip.sh
# Written by Kamil Cukrowski. Under MIT License.
set -euo pipefail

# functions ######################################################

usage() {
	local n=qqgrid_layout.sh
	cat <<EOF
Usage: $n [options] rows:columns
       $n TEST

Options:
	-r <xres>x<yres>         - Set output resolution to xres,yres. Ex. -r 1280x1024
	-x x_ratios              - Set weights of y cells in format x1:x2:x3...
	                           Missing weights are assumed to be equal 1
	-y y_ratios              - Set weights of y cells in format y1:y2:y3...
	                           Missing weights are assumed to be equal 1
	-s xpos:ypos:xend:yend   - span cell (xpos,ypos) to cell (xend,yend)
	-h                       - print this help end exit
	-d                       - draws computation output nice on the screen
	-A                       - Print absolute cell endings

Script computes cell positions in a grid_layout.

Output format:
	<x>:<y>:<width>:<height> ...

Examples
	$n 2:2
	$n -d -x 1:1:3 -y 10:2:1 -s 0:0:2:2 5:10

Wrtten by Kamil Cukrowski (C) 2017. Under MIT License.
EOF
}

foldl() { # from haskell
	local foldl_func=$1 foldl_tmp=$2
	shift 2
	while (( $# )); do
		foldl_tmp=$( $foldl_func "$foldl_tmp" "$1" )
		shift
	done
	echo "$foldl_tmp"
}

apply() { # from haskell
	local foldf_func=$1 foldf_tmp=$2
	shift 2
	while (( $# )); do
		$foldf_func "$foldf_tmp" "$1"
		foldf_tmp="$1"
		shift
	done
}

apply1_stdin() {
	local apply1_stdin_func=$1
	shift
	while (( $# )); do
		"$apply1_stdin_func" <<<"$1"
		shift
	done
}

Euclidean_2() { # Compute Euclidean between two values.
	if (($2 == 0)); then
		echo "$1"
	else
		Euclidean "$2" "$(($1%$2))"
	fi
}

Euclidean() { # Compute euclidean beatween values.
	foldl Euclidean_2 "$@"
}

run_tests() {
	# arguments are in format "function arg1 arg2|expected function output"
	local t failed=false
	for t; do

		cmd=$(echo "$t"|cut -d'|' -f1)
		expected_res=$(echo "$t"|cut -d'|' -f2)

		res=$(eval "$cmd")

		if [ "$res" != "$expected_res" ]; then
			echo "ERROR: $cmd returned vs expected resturn"
			echo "^ \"$res\""
			echo "^ \"$expected_res\""
			failed=true
		else
			echo "+ $cmd returned \"$res\""
		fi
		
	done
	if $failed; then
		echo "ERROR - some command failed" >&2
		exit 1
	fi
}

layout_w() {
	# layout compute weights distances
	local i=0 w euclidean tmp

	# devide via common dividend
	euclidean=$(Euclidean "$@")
	for w; do
		echo -n "$i "
		(( i += w / euclidean )) ||:
	done
	echo "$i"
}

array_print() {
	if (($#)); then
		printf "%s\n" "$@"
	fi
}


check() { 
	if eval "$1"; then :; else
		eval "echo \"ERROR: check: \$1 => $1\"" >&2;
		echo "ERROR: $2" >&2;
		exit 1; 
	fi; 
}

check_number() { 
	check '[ "$'"$1"'" -eq "$'"$1"'" ] 2>/dev/null' "${2:-}"; 
}

check_number_greater_equal() {
	check '[[ "$'"$1"'" -eq "$'"$1"'" && "$'"$1"'" -ge "'"$2"'" ]] 2>/dev/null' "${3:-}";
}

check_number_range() {
	check '[[ "$'"$1"'" -eq "$'"$1"'" && "$'"$1"'" -ge "'"$2"'" && "$'"$1"'" -le "'"$3"'" ]] 2>/dev/null' "${4:-}";
}

grid_layout() {
	set -euo pipefail
	IFS=$' \t\n'

	local tmp retstr x y x1 y1 x2 y2
	local RELATIVE_END=true
	local -a ret resolution=() xratios=() yratios=() span=()

	# parse arguments #############
	tmp=$(getopt -o r:x:y:s:R -n 'grid_layout' -- "$@")
	eval set -- "$tmp"
	while true; do
		case "$1" in
		-r)
			IFS=x read -r -a resolution <<<"$2";
			check '[ ${#resolution[@]} -eq 2 ]' 'Wrong number of resolution numbers'
			while read -r x; do
				check_number x "One of -r values =\"$x\" is not a number"
			done < <(array_print "${resolution[@]}");
			shift 2; 
			;;
		-x)
			IFS=: read -r -a xratios <<<"$2";
			while read -r x; do
				check_number x "One of -x values =\"$x\" is not a number"
				check_number_greater_equal x 1 "One of -y values =\"$x\" is lower then 1"
			done < <(array_print "${xratios[@]}");
			shift 2;
			;;
		-y)
			IFS=: read -r -a yratios <<<"$2";
			while read -r x; do
				check_number x "One of -y values =\"$x\" is not a number"
				check_number_greater_equal x 1 "One of -y values =\"$x\" is lower then 1"
			done < <(array_print "${yratios[@]}")
			shift 2
			;;
		-s) 
			span+=($2);
			shift 2; 
			;;
		-A) RELATIVE_END=false; shift; ;;
		--) shift; break; ;;
		*) echo "Internal error"; exit 1; ;;
		esac
	done

	local xsize ysize
	IFS=: read xsize ysize <<<"$1"
	shift

	# sanity checks #################
	for i in xsize ysize; do
		check_number_greater_equal $i 1 "Value of $i is not a number or is greater or equal to 1"
	done
	check '[[ ${#xratios[@]} -eq 0 || ${#xratios[@]} -le $xsize ]]' 'The count of X ratios values must be lower then rows count'
	check '[[ ${#yratios[@]} -eq 0 || ${#yratios[@]} -le $ysize ]]' 'The count of Y ratios values must be lower then columns count'
	check '[[ ${#span[@]} -lt $((xsize*ysize)) ]]' 'there cannot be more span arguments then the size of whole array'

	# initilize ret array
	tmp=$(
		for y in $(seq 0 $((ysize-1)) ); do
			for x in $(seq 0 $((xsize-1)) ); do
				echo "$x:$y:$((x+1)):$((y+1))"
			done
		done
	)
	ret=($tmp)

	ret_idx() {
		local idx=$(( $1+$2*xsize ))
		if [ "$idx" -gt "${#ret[@]}" ]; then echo "ERROR - $1,$2 -> $idx -gt ${#ret[@]}" >&2; exit 2; fi;
		echo "$idx"
	}

	# take x and y spans into account
	local xpos ypos xend yend ix iy
	while IFS=: read xpos ypos xend yend ; do

		# sanity
		for i in xpos xend; do 
			check_number $i "Span x value \"$i\"=\"${!i}\" is not a number"
			check_number_range $i 0 $(( xsize-1 )) "Span x value \"$i\"=\"${!i}\" must be greater then 0 and lower then (xsize-1)=$((xsize-1))" 
		done
		for i in ypos yend; do 
			check_number $i "Span y value \"$i\"=\"${!i}\" is not a number"
			check_number_range $i 0 $(( ysize-1 )) "Span y value \"$i\"=\"${!i}\" must be greater then 0 and lower then (ysize-1)=$((ysize-1))" 
		done

		# check for any removed values in the quadrat
		for iy in $(seq "$ypos" "$yend"); do
			for ix in $(seq "$xpos" "$xend"); do
				tmp=$(ret_idx "$ix" "$iy")
				IFS=: read -r x1 y1 x2 y2 <<<"${ret[tmp]}"
				check '[[ $x1 -eq $ix && $y1 -eq $iy ]]'   'Internal sanity check failed on ret_idx function'
				check '[[ $x1 -ne $x2 && $y1 -ne $y2 ]]' 'Cell was already removed by another span operation'
			done
		done

		# overwrite width and length
		tmp=$(ret_idx "$xpos" "$ypos")
		IFS=: read -r x1 y1   _  _ <<<"${ret[tmp]}"
		# echo "$x:$y:$x1:$y1:$x2:$y2" >&2
		ret[tmp]=$x1:$y1:$((x1+xend-xpos+1)):$((y1+yend-ypos+1))

		# remove all values in the quadrat except the one resized
		for iy in $(seq "$ypos" "$yend"); do
			for ix in $(seq "$xpos" "$xend"); do
				if [[ $ix -ne $xpos || $iy -ne $ypos ]]; then
					tmp=$(ret_idx "$ix" "$iy")
					ret[$tmp]=0:0:0:0
				fi
			done
		done
		#array_print ret

	done < <(array_print "${span[@]}")

	# all points on our plane
	local -a xpoints ypoints
	xpoints=( $(layout_w $( for i in $(seq 0 $((xsize-1))); do echo ${xratios[$i]:-1}; done; ) ) )
	ypoints=( $(layout_w $( for i in $(seq 0 $((ysize-1))); do echo ${yratios[$i]:-1}; done; ) ) )

	# remove 0:0:0:0 values and remove indices
	# after this point there is no ret array , there is retstr string
	retstr=$(
		while IFS=: read x1 y1 x2 y2; do
			if [ $x1 -eq $x2 ] && [ $y1 -eq $y2 ]; then
				continue
			fi
			echo "${xpoints[$x1]}:${ypoints[$y1]}:${xpoints[$x2]}:${ypoints[$y2]}"
		done < <(array_print "${ret[@]}")
	)

	# multiply values bcby screen size
	if [ ${#resolution[@]} -ne 0 ]; then
		local xres yres xpoints_max ypoints_max xpart x1 y1 x2 y2

		xres=${resolution[0]}
		yres=${resolution[1]}

		xpoints_max=$(printf "%s\n" "${xpoints[@]}" | sort -n | tail -n1)
		ypoints_max=$(printf "%s\n" "${ypoints[@]}" | sort -n | tail -n1)

		retstr=$(
			while IFS=: read x1 y1 x2 y2; do
				echo "$(( 
						x1 * xres/xpoints_max )):$(( 
						y1 * yres/ypoints_max )):$(( 
						x2 == xpoints_max ? xres : x2*xres/xpoints_max )):$(( 
						y2 == ypoints_max ? yres : y2*yres/ypoints_max 
				))"
			done <<<"$retstr"
		)
	fi

	# relative second position ?
	if $RELATIVE_END; then
		retstr=$(
			while IFS=: read x1 y1 x2 y2; do
				echo "$x1:$y1:$((x2-x1)):$((y2-y1))"
			done <<<"$retstr"
		)
	fi

	ret=($retstr)
	echo "${ret[@]}"
}

grid_layout_test() {
	local -a tests
	tests=(
		"grid_layout -A 2:2|0:0:1:1 1:0:2:1 0:1:1:2 1:1:2:2"
		"grid_layout -A 3:5|0:0:1:1 1:0:2:1 2:0:3:1 0:1:1:2 1:1:2:2 2:1:3:2 0:2:1:3 1:2:2:3 2:2:3:3 0:3:1:4 1:3:2:4 2:3:3:4 0:4:1:5 1:4:2:5 2:4:3:5"
		"grid_layout 2:2|0:0:1:1 1:0:1:1 0:1:1:1 1:1:1:1"
		"grid_layout -A -r 1001x1001 -x 5:2:18 -y 2:1 3:2|0:0:200:667 200:0:280:667 280:0:1001:667 0:667:200:1001 200:667:280:1001 280:667:1001:1001"
		"grid_layout -r 1001x1001 -x 1:1:1 -y 1:1 3:2|0:0:333:500 333:0:334:500 667:0:334:500 0:500:333:501 333:500:334:501 667:500:334:501"
		"grid_layout -r 1001x1001 -x 2:2:2 -y 2:2 3:2|0:0:333:500 333:0:334:500 667:0:334:500 0:500:333:501 333:500:334:501 667:500:334:501"
		"grid_layout -r 1001x1001 -x 3:3:3 -y 3:3 3:2|0:0:333:500 333:0:334:500 667:0:334:500 0:500:333:501 333:500:334:501 667:500:334:501"
		"grid_layout -s 0:0:0:2 -s 1:0:2:1 -s 1:2:2:2 3:3|0:0:1:3 1:0:2:2 1:2:2:1"
	)
	run_tests "${tests[@]}"
}

grid_draw() {
	local pencils_pos x1 y1 x2 y2 x2_max
	local -a pencils

	pencil='A'
	pencil_pos=$(printf "%d\n" "'$pencil'")
	pencil_draw() { echo -n "$pencil"; }
	pencil_next() { (( pencil_pos += 1 )); pencil=$(printf "\x$(printf "%x" $pencil_pos)"); }

	pos() { echo -ne "\033[$(($1));$(($2))H"; }
	clrscr() { echo -ne "\033[2J"; }

	xsize=$(printf '%s\n' "$@" | cut -d':' -f3 | sort -n | tail -n1)
	ysize=$(printf '%s\n' "$@" | cut -d':' -f4 | sort -n | tail -n1)

	clrscr
	pos 0 0

	local draw_axis=true
	if $draw_axis; then
		echo -n '+--'; for i in $(seq 0 $((xsize-1))); do echo -n ${i: -1:1}; done; echo '--> x'
		echo '|'
		for i in $(seq 0 $((ysize-1))); do 
			echo ${i: -1:1}
		done
		echo '|'
		echo 'V'
		echo 'y'
	fi

	local yoff=3 xoff=4 # offset values
	while IFS=: read x1 y1 x2 y2; do # read values
		# draw current cell
		for y in $(seq $y1 $(( y2 - 1 ))); do
			for x in $(seq $x1 $(( x2 - 1 ))); do
				pos $(( yoff + y )) $(( xoff + x ))
				pencil_draw
			done
		done
		# next pencil
		pencil_next
	done < <(printf '%s\n' "${@}")

	pos $(( yoff + ysize + 4 )) 0
	echo
	echo grid_draw "$@"
}

grid_draw_test() {
	grid_draw $(grid_layout -R -r 30x20 -s 0:0:0:2 -s 3:0:3:3 -s 1:2:2:2 -s 0:3:2:3 -s 2:0:2:1 -x 4:1:1:5 -y 3:1:4:1 10:4)
}

# main #########################################################

if [ $# -eq 0 ]; then usage; exit 1; fi
tmp=$(getopt -o r:x:y:s:htdA -n 'grid_layout.sh' -- "$@")
eval set -- "$tmp"
args=() DRAW=false
while true; do
	case "$1" in
	-A) args+=("$1"); shift 2; ;;
	-r) args+=( "$1" "$2" ); shift 2; ;;
	-x) args+=( "$1" "$2" ); shift 2; ;;
	-y) args+=( "$1" "$2" ); shift 2; ;;
	-s) args+=( "$1" "$2" ); shift 2; ;;
	-h) usage; exit 1; ;;
	-d) DRAW=true; ;;
	--) shift; break; ;;
	*) echo "Internal error"; exit 1; ;;
	esac
done
if [ $# -eq 0 ]; then usage; exit 1; fi

if [ "$1" == TEST ]; then
	grid_layout_test
	grid_draw_test
	exit 0
fi

if ! $DRAW; then
	grid_layout "${args[@]}" "$@"
else
	grid_draw "$(grid_layout "${args[@]}" "$@")"
fi
