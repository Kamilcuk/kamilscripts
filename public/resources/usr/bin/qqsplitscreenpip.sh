#!/bin/bash
# file qqsplitscreenpip.sh
# Written by Kamil Cukrowski
set -euo pipefail
# functions ###############################################################

usage() {
	local n
	n=qqsplitscreenpip.sh
	cat >&2 <<EOF
Usage: $n -[options] test|auto|gui|grid [additional params...]

Description:
	Script inspired by "LG Screen Split (PIP)"
	Watch ex. https://youtu.be/gRktqmYzXco?t=47
	Script moves and reseises windows on current desktop,
	depending on the mdoe (screen layout) you choose

Mode:
	auto [count]  - auto mode, tries to guess mode from window count
	                it may take also parameter, which forces window count to specified
	gui           - pops out graphical chooser
	grid          - passes grid options to grid_layout and sets windows
	test          - run internal test, used in development only

Options:
	-h            - print this help and exit
	-v            - more verbose ouptut
	-t            - test mode, don't move windows. Implicates -v

Options passed to grid_layout:
	-x x_ratios
	-y y_ratios
	-s row:col:rowSpan:colSpan
	-R xcount:ycount

Examples:
	$n auto
	$n gui

Written by Kamil Cukrowski (C) 2017. Under MIT license. Version 1.0.1
EOF
cat >/dev/null <<EOF
TODO:
- script fails to unmaximize windows
- PIP hover option - automagically on top

Remeber axis:
+-----------------------> X
|                   |
|                   |
|                   h
|                   e
|                   i
|                   g
|                   h
|                   t
|                   |
|-------width-------+
|
|
v 

Y

EOF
}

error() { echo "ERROR: " "$@" >&2; }
warning() { echo "WARN : " "$@" >&2; }
fatal() { echo "FATAL: $@" >&2; exit 1; }
verbose() { if ${VERBOSE:-false}; then echo "$@"; fi; }
debug() { if ${DEBUG:-false}; then echo "$@"; fi; }
verbose_var_column() { verbose $var; verbose "${!var}" | column -t; verbose; }

checkUtilities() {
	for i in sed bc xwininfo wmctrl cut xdotool xargs; do
		if ! hash $i >/dev/null; then
			fatal "${FUNCNAME[0]} - utlity $i not found."
		fi
	done
	if [ ${BASH_VERSION%%.*} -lt 4 ]; then
		fatal "BASH_VERSION is lower then 4"
	fi
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

# screen functions ###########################################################################################

getPanelHeight() {
	# add more panels if needed
	local w
	w="$(wmctrl -l | tr -s ' ' | cut -d' ' -f1,4-)"
	if echo "$w" | grep -q "xfce4-panel"; then
		xdotool getwindowgeometry -shell $(echo "$w" | grep xfce4-panel | cut -d' ' -f1) | grep HEIGHT | cut -d'=' -f2
	else
		warning "${FUNCNAME[0]} - unknown panel - returning 20" >&2
		echo "20"
	fi
}

getScreenGeometry() {
	xwininfo -root | awk '/-geometry/{gsub(/+|x/," ");print $2,($3-'"$(getPanelHeight)"')}'  
}

getWinsOnCurrentDesktop() {
	wmctrl -l | awk -v var=$(xdotool get_desktop) '{if ($2 == var) print $1;}'
}

getBorderInfo() {
	# http://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately-including-decoration
	# returns: left right top bottom
	xprop _NET_FRAME_EXTENTS -id "$1" | cut -d'=' -f2- | tr -d ' ' | tr ',' ' ' 
}

getWinsInfoOnCurrentDesktop() {
	# output format: WINDOWID:X:Y:WIDTH:HEIGHT:SCREEN:
	# WINDOW X Y WIDTH HEIGHT SCREEN BORDERLEFT BORDERRIGHT BORDERTOP BORDERBOTTOM
	local w
	w=$(getWinsOnCurrentDesktop)
	for w in $w; do
		echo "$w $(xdotool getwindowgeometry --shell $w|cut -d= -f2|tr '\n' ' ') $(getBorderInfo $w)"
	done
}

# grid layout functions ########################################################################################

# pair destinations with windows functions ################################################################################33

calculateArea() {
	# arguments: x1 y1 x2 y2
	echo "$(( ( x2>x1 ? x2-x1 : x1-x2 ) * ( y2>y1 ? y2-y1 : y1-y2 ) ))"
}

caculateCover_2D() {
	# arguments: x1 x2 X1 X2
	# arguments: a c A C
	read a c A C <<<"$@"
	echo "$(( 
		a<A ?
			c<A ?
				0
				: 
				c<C ? 
					c-A
					:
					C-A
			:
			a<C ?
				c<C ? 
					c-a
					:
					C-a
				:
				0
	))"
}

caculateCover_2D_test() {
	local -a tests
	tests=(
		"0 1 2 4|0"
		"0 2 2 4|0"
		"0 3 2 4|1"
		"0 4 2 4|2"
		"1 4 2 4|2"
		"3 4 2 4|1"
		"1 5 2 4|2"
		"4 5 2 4|0"
		"5 6 2 4|0"
	)
	run_tests "${tests[@]/#/caculateCover_2D }"
}

calculateCover() {
	# arguments: x1 y1 x2 y2 x3 y3 x4 y4
	# output: cover of rectanglne (x1,y1,x2,y2) over recrangle (x3,y3,x4,y4)
	echo $(( $(caculateCover_2D $1 $3 $5 $7) * $(caculateCover_2D $2 $4 $6 $8) ))
}

calculateCover_test() {
	local -a tests
	tests=(
		"0 0 2 2 2 2 4 4|0"
		"0 0 6 6 2 2 4 4|4"
		"0 0 3 3 2 2 4 4|1"
		"0 0 3 4 2 2 4 4|2"
		"2 2 3 4 2 2 4 4|2"
		"3 3 4 4 2 2 4 4|1"
		"4 4 5 5 2 2 4 4|0"
	)
	run_tests "${tests[@]/#/calculateCover }"
}

pairWindowsOnGrid()
{
	local tmp cx cy cwidth cheight ccnt id window wx wy wwidth wheight wscreen bleft bright btop bbottom border
	local cells="$1" # IFS=: read cx cy cwidth cheight
	local wins="$2" # IFS=: read id window wx wy wwidth wheight wscreen bleft bright btop bbottom
	local winscnt=$(wc -l <<<"$2")

	# calculate distance between every window and cell
	wins=$(
		while read wins_line; do
			IFS=' ' read _ _ wx wy wwidth wheight _ <<<"$wins_line"
			while read cells_line; do
				read cx cy cwidth cheight <<<"$cells_line"
				echo "$cells_line $(
					calculateCover $cx $cy $((cx+cwidth)) $((cy+cheight)) $wx $wy $((wx+wwidth)) $((wy+wheight))
				) $wins_line"
			done <<<"$cells"
		done <<<"$wins"
	)
	if $VERBOSE; then echo "wins_on_cells"; echo "$wins" | column -t; echo; fi >&2

	# add windows counter to the end of the cell
	cells=$(sed 's/$/ 0/' <<<"$cells") # read cx cy cwidth cheight ccnt

	# run as many times as there are windows
	for i in $(seq $winscnt); do

			# find cell with smallest number of windows on it
			tmp=$(sort -k5 -n <<<"$cells" | head -n1)
			IFS=' ' read cx cy cwidth cheight ccnt <<<"$tmp"

			# find unpaired window that is the best for this cell - has biffest calculated cover
			tmp=$(grep "^$cx $cy " <<<"$wins" | sort -k5 -n | tail -n1)
			IFS=' ' read cx cy cwidth cheight dist id window wx wy wwidth wheight wscreen bleft bright btop bbottom <<<"$tmp"

			# window id should be moved to $cx $cy $cwidth $cheight with respect to borders
			echo "$id $((cx)) $((cy)) $((cwidth-bleft-bright)) $((cheight-btop-bbottom))" # why? 
			#echo "$id $((cx)) $((cy)) $((cwidth-bright-bleft)) $((cheight-bbottom-btop))" # why? 

			# remove window id from wins_cover, it is used
			wins=$(awk "\$6 != \"$id\"" <<<"$wins")
			# increment cell windows counter
			cells=$(
				grep -v "^$cx $cy " <<<"$cells";
				echo "$cx $cy $cwidth $cheight $((ccnt+1))";
			)
	done

	if [ -n "$wins" ]; then
		fatal "not all windows covered, which is indefinitly strange"
	fi
}

setWins_in() {
	local cmd="${cmd:-:}"
	# parallel - better performance with many windows
	while read id x y width height; do
		(
			$cmd
			# remove "Always on top" property
			wmctrl -i -r $id -b remove,above 
			# unmaximize
			wmctrl -i -r $id -b remove,maximized_vert,maximized_horz
			# reseize and move to specified position
			wmctrl -i -r $id -e 0,$x,$y,$width,$height
		) &
	done <<<"$@"
	wait
}
setWins() {
	local cmd=':'
	if $VERBOSE; then
		cmd='set -x'
	fi
	setWins_in "$@"
	setWins_in "$@"
}

# auto guess ######################################################33

modeAutoGuess() {
	local cnt=$1
	local x=1 y=1
	while (( (x*y) < cnt )); do
		if [ $x -le $y ]; then
			(( x+=1 ))
		else
			(( y+=1 ))
		fi
	done
	if (( (x*y) > cnt )); then
		echo -n "-s 0:0:0:$(( (x*y) - cnt )) "
	fi
	echo "-R $x:$y grid"
}

######################## main ###########################
######################## globals ########################

DEBUG=${DEBUG:-false}
VERBOSE=${VERBOSE:-false}
SPEED=${SPEED:-false}
$DEBUG && set -x
$SPEED && PS4='$(date "+%s.%N ($LINENO) + ")'

######################## locals #########################
######################## getopt #########################

if [ $# -eq 0 ]; then usage; exit 1; fi
tmp=$(getopt -o R:x:y:s:htv -n 'qqsplitscreenpip.sh' -- "$@")
eval set -- "$tmp"
grid_args=() TEST=false
while true; do
	case "$1" in


	# grid_layout options
	-R) grid_args+=( "$2" ); shift; ;;
	-x) grid_args+=( "$1" "$2" ); shift; ;;
	-y) grid_args+=( "$1" "$2" ); shift; ;;
	-s) grid_args+=( "$1" "$2" ); shift; ;;

	-t) TEST=true; VERBOSE=true; ;;
	-v) VERBOSE=true; ;;
	-h) usage; exit 1; ;;
	--) shift; break; ;;
	*) echo "Internal error"; exit 1; ;;
	esac
	shift
done
if [ $# -eq 0 ]; then usage; exit 1; fi


rerun() {
	local -a myargs=()
	if $VERBOSE; then 
		myargs+=(-v);
	fi;
	if $TEST; then
		myargs+=(-t);
	fi;
	verbose "+ exec $0 ${myargs[@]} $*"
	exec "$0" "${myargs[@]}" "$@"
}


grid_layout="qqgrid_layout.sh"
if ! hash "$grid_layout" 2>/dev/null; then
	warning "Command $grid_layout was not found in path"
	if -x "./qqgrid_layout.sh"; then
		grid_layout="./qqgrid_layout.sh"
		warning "Using $grid_layout as grid_layout"
	else
		fatal "Command grid_layout could not be found"
	fi
fi

case "$1" in
test)
	caculateCover_2D_test
	calculateCover_test
	;;
auto)
	window_cnt=${2:-$(getWinsOnCurrentDesktop | wc -w)}
	tmp=$(modeAutoGuess $window_cnt)
	verbose "modeAutoGuess $window_cnt returned \"$tmp\""
	rerun "${myargs[@]}" $tmp
	;;
gui)
	ans=$( zenity --list \
		--title "qq Screen Split (PIP)" \
		--text "Mode for OnScreenDisplay?" \
		--radiolist --column "Pick" --column "Mode" \
		FALSE "auto" \
		FALSE "1 screen" \
		TRUE  "2 screen vertical 1:1"   \
		FALSE "2 screen vertical 16:5"  \
		FALSE "2 sceeen horizontal 1:1" \
		FALSE "3 screen vertical left 1:1:1" )
	case "$ans" in
	"auto")                         rerun auto; ;;
	"1 screen")                     rerun -R 1:1 grid; ;;
	"2 screen vertical 1:1")        rerun -R 2:1 grid; ;;
	"2 screen vertical 16:5")       rerun -x 16:5 -R 2:1 grid; ;;
	"2 sceeen horizontal 1:1")      rerun -R 1:2 grid; ;;
	"3 screen vertical left 1:1:1") rerun -R 1:3 grid; ;;
	esac
	;;
grid)
	screen_geometry=$(getScreenGeometry|tr ' ' 'x') #|while read x y; do echo ${x}x$(( y-$(getPanelHeight) )); done)
	verbose_var_column screen_geometry
	verbose_var_column grid_args
	grid=$(./qqgrid_layout.sh -r $screen_geometry "${grid_args[@]}" | tr ' ' '\n' | tr ':' ' ')
	verbose_var_column grid
	wins=$(getWinsInfoOnCurrentDesktop)
	verbose_var_column wins
	wins_grid=$(pairWindowsOnGrid "$grid" "$wins")
	verbose_var_column wins_grid
	if $TEST; then
		wmctrl() { echo "wmctrl $*"; }
	fi
	setWins "$wins_grid"
	;;
*) usage; exit 1; ;;
esac
