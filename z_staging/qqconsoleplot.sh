#!/bin/bash -eu

consolesizecols=40 #$(tput lines)
consolesizelines=80 #$(tput cold)
x=( $(seq 0 5 60) )
y=( 0 8 5 10 5 20 20 37 29 20 10 0 )
points=${#y[*]}

################################### fcuntions ###########################3

matrix_new() {
	local sizex=${2:-0}
	local sizey=${3:-0}
	matrix_write "$1" sx $sizex
	matrix_write "$1" sy $sizey
	for xi in $(seq 1 $(matrix_read "$1" sx)); do
		for yi in $(seq 1 $(matrix_read "$1" sy)); do
			matrix_write "$1" $xi,$yi " "
		done
	done
}

matrix_write() {
 	eval $1[$2]="\"$3\""
}

matrix_write_line() {
	local str=$3
	for ((i=0;i<${#str};++i)); do
		matrix_write "$1" "$2,$((i+1))" "${str:$i:1}"
	done
}

matrix_write_column() {
	local str=$3
	for ((i=0;i<${#str};++i)); do
		matrix_write "$1" "$((i+1)),$2" "${str:$i:1}"
	done
}

matrix_read() {
 	eval echo "\"\${$1[$2]}\""
}

matrix_print() {
	local itex="${2:-$(seq 1 $(matrix_read "$1" sx))}"
	local itey="${3:-$(seq 1 $(matrix_read "$1" sy))}"
	local val=""
	local str=""
	for xi in $itex; do
		for yi in $itey; do
			val="$(matrix_read "$1" $xi,$yi)"
			str+="${val}"
		done
		str+="
"
	done
	echo -n "$str"
}

matrix_print_transposeX() {
	matrix_print "$1" "$(seq 1 $(matrix_read "$1" sx)|tac)" "$(seq 1 $(matrix_read "$1" sy))"
}

printlines() {
	local mode=${2:-unicode}
	case $mode in
	unicode)
		case "$1" in
		v)	env printf '\u2502'; ;;
		h)	env printf '\u2500'; ;;
		ur)	env printf '\u2514'; ;;
		ul)	env printf '\u2518'; ;;
		dr)	env printf '\u250c'; ;;
		dl)	env printf '\u2510'; ;;
		esac
		;;
	env)
		for i in v h ur ul dr dl; do
			eval box$i="$(printlines "$i")"
			eval export box$i
		done
		dot=$(env printf '\u2000')
		export dot
		;;
	esac
}

create_axis() {
	printlines "" env
	for i in $(seq 2 $((consolesizecols-3))); do
		if [ $(((i-1)%10)) -eq 0 ]; then
			matrix_write "$1" "$i,1" $(((i-1)/10%100))
		else
			matrix_write "$1" "$i,1" $boxv
		fi
	done
	matrix_write "$1" "$((consolesizecols-2)),1" "^"
	matrix_write "$1" "$((consolesizecols-1)),1" " "
	matrix_write "$1" "$((consolesizecols-0)),1" "Y"
	for i in $(seq 2 $((consolesizelines-3))); do
		if [ $(((i-1)%10)) -eq 0 ]; then
			matrix_write "$1" "1,$i" $(((i-1)/10%100))
		else
			matrix_write "$1" "1,$i" $boxh
		fi
	done
	matrix_write "$1" "1,$((consolesizelines-2))" ">"
	matrix_write "$1" "1,$((consolesizelines-1))" " "
	matrix_write "$1" "1,$((consolesizelines-0))" "X"
	matrix_write "$1" "1,1" $boxur
}

draw_points() {
	for i in $(seq 0 $(($points-1))); do
		matrix_write "$1" $((${y[$i]}+1)),$((${x[$i]}+1)) "$i"	
	done
}

connect_points() {
	for i in $(seq 1 $(($points-1))); do
		x1=${x[$(($i-1))]}
		x2=${x[$i]}

		y1=${y[$(($i-1))]}
		y2=${y[$i]}

		dx=$(((x2 - x1)))
    	dy=$(((y2 - y1)))
		for x in $(seq $x1 $x2); do
	  		y="$(printf "%.0f" "$(echo "$y1+$dy*($x-$x1)/$dx" | bc)")"
  			if  ! [[ $x -eq $x1 && $y -eq $y1 ]] &&
	  			! [[ $x -eq $x2 && $y -eq $y2 ]]; then
				matrix_write "$1" $(($y+1)),$(($x+1)) "+"
			fi
		done
	done
}

##########################3 main ##############################

declare -A screen
matrix_new screen $consolesizecols $consolesizelines

create_axis screen

draw_points screen

connect_points screen

matrix_print_transposeX screen


