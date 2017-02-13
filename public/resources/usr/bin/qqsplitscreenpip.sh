#!/bin/bash -eu
# file qqsplitscreenpip.sh
# Written by Kamil Cukrowski
# under BeerWare license
# i am waiting for soo many beers!
######################## functions ######################

usage() {
	echo '
Usage:
	qqsplitscreenpip.sh -[a|g|1|2|2v|2v_16:5|3vl]

Description:
	Script inspired by "LG Screen Split (PIP)"
	Watch ex. https://youtu.be/gRktqmYzXco?t=47
	Script moves and reseises windows on current desktop,
	depending on the mdoe (screen layout) you choose
	
Options:
	-a          - auto mode, tries to guess mode from window count
	-g          - pops out graphical chooser
	-1          - one scren only
	-2          - same as -2v
	-2v         - two screen verticaly 1:1
	-2v_16:5    - two screen vertivally 16:5
	-2h         - two screen horizontaly 1:1
	-3vl        - three screen vertically left 1:1:1

Examples:
	qqsplitscreenpip.sh -1
	qqsplitscreenpip.sh -g
	qqsplitscreenpip.sh -2v

Notice:
	Written by Kamil Cukrowski
	Under BeerWare license
	Version 0.1
'
echo >/dev/null '
INFO:
- if you would like to add more options/modes, edit populateDestinations()
TODO:
- script fails to unmaximize windows
- options like -2v_x:y -> two screen vertically with ratio x:y
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

'
}

checkUtilities() {
	for i in sed bc xwininfo wmctrl cut xdotool; do
		if ! hash $i >/dev/null; then
			echo "ERROR - ${FUNCNAME[0]} - utlity $i not found."
			exit 1
		fi
	done
}

getPanelHeight() 
{
	local  wmctrll="$(wmctrl -l)"
	case "$wmctrll" in
	*"xfce4-panel"*)
		xdotool getwindowgeometry -shell $(echo "$wmctrll" | grep xfce4-panel | cut -d' ' -f1) | grep HEIGHT | cut -d'=' -f2
		;;
	*)
		echo "WARNING - ${FUNCNAME[0]} - unknownn panel - returning 20" >&2
		echo "20"
		;;
	esac
}

getScreenGeometry()
{
	xwininfo -root | awk '/-geometry/{gsub(/+|x/," ");print $2,($3-'"$(getPanelHeight)"')}'  
}

getWinsOnCurrentDesktop()
{  
	wmctrl -l | awk -v var=$(xdotool get_desktop) '{if ($2 == var) print $0;}' | cut -d' '  -f1
}

populateWinsInfo() 
{
	local wins
	local WINDOW X Y WIDTH HEIGHT SCREEN
	wins="$(getWinsOnCurrentDesktop)"
	local i
	i=0;
	for w in $wins; do
		i=$((i+1))
		eval $(xdotool getwindowgeometry --shell $w)
		winsinfo[windowhex_$i]=$w
		#winsinfo[window_$i]=$WINDOW
		winsinfo[x_$i]=$X
		winsinfo[y_$i]=$Y
		winsinfo[width_$i]=$WIDTH
		winsinfo[height_$i]=$HEIGHT
		#winsinfo[screen_$i]=$SCREEN
		#winsinfo[midX_$i]=$((winsinfo[x_$i]+winsinfo[width_$i]/2))
		#winsinfo[midY_$i]=$((winsinfo[y_$i]+winsinfo[height_$i]/2))
	done
	winsinfo[size]=$i;
}

printWinsInfo() {
	local var=${1:-winsinfo}
	eval echo "\"$var[size]=\${$var[size]}\""
	for i in $(eval seq \${$var[size]}); do
		eval echo "\"$var[windowhex_$i]=\${$var[windowhex_$i]}
$var[window_$i]=\\\${$var[window_$i]}
$var[x_$i]=\${$var[x_$i]}
$var[y_$i]=\${$var[y_$i]}
$var[width_$i]=\${$var[width_$i]}
$var[height_$i]=\${$var[height_$i]}
$var[screen_$i]=\\\${$var[screen_$i]}
$var[midX_$i]=\\\${$var[midX_$i]}
$var[midY_$i]=\\\${$var[midY_$i]}\""
	done
}

getBorderInfo()
{
	# http://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately-including-decoration
	local id="${1}"
	xprop _NET_FRAME_EXTENTS -id "$id" | \
		grep "NET_FRAME_EXTENTS" | \
		cut -d '=' -f 2 | \
		tr -d ' ' | tr ',' ' ' 
}

populateBorderInfo() {
	local borders
	borders=( $(getBorderInfo "$1") )
	borderinfo[0]=${borders[0]}
	borderinfo[1]=${borders[1]}
	borderinfo[2]=${borders[2]}
	borderinfo[3]=${borders[3]}
	borderinfo["width of left border"]=${borders[0]}
	borderinfo["width of right border"]=${borders[1]}
	borderinfo["height of title bar"]=${borders[2]}
	borderinfo["height of bottom border"]=${borders[3]}
	# declare -p borderinfo
}

populateDestinations() {
	# this is screen split chooser
	local mode="${1}"
	local geo=( $(getScreenGeometry) )
	case "$mode" in
	1)
		destinations[x_1]=0
		destinations[y_1]=0
		destinations[width_1]=$(( geo[0] - destinations[x_1] ))
		destinations[height_1]=$((geo[1] - destinations[y_1] ))
		destinations[size]=1
		;;
	2|2v) # 2 screen vertivally 1:1
		destinations[x_1]=0
		destinations[y_1]=0
		destinations[width_1]=$(( geo[0]/2 ))
		destinations[height_1]=$((geo[1]))

		destinations[x_2]=$(( destinations[width_1] ))
		destinations[y_2]=0
		destinations[width_2]=$(( geo[0] - destinations[x_2] ))
		destinations[height_2]=$((geo[1] - destinations[y_2] ))
		destinations[size]=2
		;;
	2v_16:5) # 2 screen vertivally 16:5
		local sum=$((16+5))

		destinations[x_1]=0
		destinations[y_1]=0
		destinations[width_1]=$(( geo[0]*16/sum ))
		destinations[height_1]=$((geo[1] - destinations[y_1]))

		destinations[x_2]=$(( destinations[width_1] ))
		destinations[y_2]=0
		destinations[width_2]=$(( geo[0] - destinations[x_2] ))
		destinations[height_2]=$((geo[1] - destinations[y_2] ))
		destinations[size]=2
		;;
	2h) # 2 screen horizontally
		destinations[x_1]=0
		destinations[y_1]=0
		destinations[width_1]=$(( geo[0]))
		destinations[height_1]=$((geo[1]/2))

		destinations[x_2]=0
		destinations[y_2]=$((destinations[height_1]))
		destinations[width_2]=$(( geo[0] - destinations[x_2] ))
		destinations[height_2]=$((geo[1] - destinations[y_2] ))
		destinations[size]=2
		;;
	3|3vl) # 3 screem vertically left
		destinations[x_1]=0
		destinations[y_1]=0
		destinations[width_1]=$(( geo[0]/2 ))
		destinations[height_1]=$((geo[1]))

		destinations[x_2]=$(( destinations[width_1] ))
		destinations[y_2]=0
		destinations[width_2]=$(( geo[0] - destinations[x_2] ))
		destinations[height_2]=$(( geo[1]/2 ))

		destinations[x_3]=$(( destinations[x_2] ))
		destinations[y_3]=$(( destinations[height_2] ))
		destinations[width_3]=$((  geo[0] - destinations[x_3] ))
		destinations[height_3]=$(( geo[1] - destinations[y_3] ))
		destinations[size]=3
		;;
	*)
		echo "ERROR - ${FUNCNAME[0]} - not implemented"
		exit 1
		;;
	esac

	# sanity checks 
	if [ ${destinations[size]} -ne ${destinations[size]} ]; then
		echo "ERROR - ${FUNCNAME[0]} - \${destinations[size]} is not a number"
		exit 1
	fi
	for i in $(seq ${destinations[size]}); do
		for n in x y width height; do
			if eval [ -z "\"\${destinations[${n}_$i]}\"" ]; then
				eval echo "\"ERROR - ${FUNCNAME[0]} - destinations[${n}_$i] is empty - \${destinations[${n}_$i]} \""
				exit 1
			fi
		done
	done
	#declare -p destinations
}

distancePoints() {
	local X1="$1" Y1="$2" X2="$3" Y2="$4"
	echo "sqrt( ($X1-$X2)^2 + ($Y1-$Y2)^2 )" | bc
}

compareFloat(){
	# ex. compareFloat 1.010101 '>' 2.300330
	# remember to put '>' and '<' in apostrophes
	[ "$(echo "${1}${2}${3}" | bc -l)" -eq 1 ]
}

floatToInt() {
	# may not work on negative numbers, but we dont care
	echo "scale=0; (${1}+0.5)/1;" | bc 
}

copyAssociativeArray() {
	# http://stackoverflow.com/questions/6660010/bash-how-to-assign-an-associative-array-to-another-variable-name-e-g-rename-t
	eval $(typeset -A -p FROM|sed 's/ FROM=/ TO=/')
}

pairWinsWithDestinations()
{
	local dist tmp smallest_value smallest_desti
	local dest_left dtimes_smallest
	local bigNumber=1000000000

	# copy exported associative variables
	local dest
	eval $(typeset -A -p destinations|sed 's/ destinations=/ dest=/')
	local wi
	eval $(typeset -A -p winsinfo|sed 's/ winsinfo=/ wi=/')

	local dtimes # dtimes[$d] represents how many windows are in specified destination $d
	declare -A dtimes
	# initialize with zeros
	for d in $(seq ${dest[size]}); do
		dtimes[$d]=0
	done

	# for every window
	for i in $(seq ${wi[size]}); do

		# find number of windows on destinations with smallest number of windows in it
		# find smallest number in dtimes
		dtimes_smallest=${bigNumber}
		for d in $(seq ${dest[size]}); do
			if [[ $dtimes_smallest -gt ${dtimes[$d]} ]]; then
				dtimes_smallest=${dtimes[$d]}
			fi
		done

		# create set of destinations with smallest number of windows on it
		# filter out all the destinations that have more than dtimes_smallest windows
		dest_left=""
		for d in $(seq ${dest[size]}); do
			if [[ ${dtimes[$d]} -le $dtimes_smallest ]]; then
				dest_left+=" $d"
			fi
		done

		# get destination from filtered destinations, that is the closest to the window
		smallest_value=${bigNumber}
		smallest_desti=0
		for d in ${dest_left}; do
			dist=$(distancePoints ${wi[x_$i]} ${wi[y_$i]} ${dest[x_$d]} ${dest[y_$d]} )
			#echo $dist $smallest_value
			#if [[ $(floatToInt $smallest_value) -gt $(floatToInt $dist) ]]; then
			if compareFloat $smallest_value '>' $dist; then
				smallest_value=$dist
				smallest_desti=$d
			fi
		done

		# this window goes to $smallest_desti destination - we increment dtimes[$d]
		d=$smallest_desti
		dtimes[$d]=$((dtimes[$d]+1))
		if [[ $d -eq 0 ]]; then
			echo "ERROR - pairWinsWithDestinations() - [[ $d -eq 0 ]] "
			exit 1
		fi

		# update return variable - take x , y , width and height from destination
		winsgoal[windowhex_$i]=${wi[windowhex_$i]}
		#winsgoal[window_$i]=${wi[window_$i]}
		winsgoal[x_$i]=${dest[x_$d]}
		winsgoal[y_$i]=${dest[y_$d]}
		winsgoal[width_$i]=${dest[width_$d]}
		winsgoal[height_$i]=${dest[height_$d]}
		#winsgoal[screen_$i]=${wi[screen_$i]}
		#winsgoal[midX_$i]=$((winsgoal[x_$i]+winsgoal[width_$i]/2))
		#winsgoal[midY_$i]=$((winsgoal[y_$i]+winsgoal[height_$i]/2))

		# adjust with boarder
		populateBorderInfo "${winsgoal[windowhex_$i]}"
		winsgoal[width_$i]=$((  winsgoal[width_$i]  - borderinfo["width of right border"] - borderinfo["width of left border"]    ))
		winsgoal[height_$i]=$(( winsgoal[height_$i] - borderinfo["height of title bar"]   - borderinfo["height of bottom border"] ))
	done
	winsgoal[size]=${wi[size]}
	#declare -p winsgoal
}

setWinsGoal_1()
{
	# parallel - better performance with many windows
	for i in $(seq ${winsgoal[size]}); do	
		(
			${1:-}

			# remove "Always on top" property
			wmctrl -i -r ${winsgoal[windowhex_$i]} -b remove,above
			# unmaximize
			wmctrl -i -r ${winsgoal[windowhex_$i]} -b remove,maximized_vert,maximized_horz

			# do the resaize part
			wmctrl -i -r ${winsgoal[windowhex_$i]} -e \
				0,${winsgoal[x_$i]},${winsgoal[y_$i]},${winsgoal[width_$i]},${winsgoal[height_$i]}
		) &
	done
	wait
}
setWinsGoal() 
{
	setWinsGoal_1 "set -x"
	# i run that twice - must be a buf in wmctrl when parallel running
	# is faster anyway
	setWinsGoal_1
}

######################## main ###########################
######################## globals ########################

DEBUG=${DEBUG:-false}
# struct { size, [ windowhex_$i, window_$i, x_$i, y_$i, heigth_$i, width_$i : i=1...size ] } winsinfo;
declare -A winsinfo
# struct { size, [ x_$i, y_$i, heigth_$i, width_$i : i=1...size ] } destinations;
declare -A destinations
# struct { size, [ windowhex_$i, window_$i, x_$i, y_$i, heigth_$i, width_$i : i=1...size ]  } winsgoal;
declare -A winsgoal
# struct { width of left border, width of right border, height of title bar, height of bottom border } borderinfo;
declare -A borderinfo

######################## locals #########################
######################## getopt #########################

case "${1:---help}" in
-a)
	$0 -"$(getWinsOnCurrentDesktop | wc -w)"
	;;
-g)
	ans=$( zenity --list \
		--title "qq Screen Split (PIP)" \
		--text "Mode for OnScreenDisplay?" \
		--radiolist --column "Pick" --column "Mode" \
		FALSE "1 screen" \
		TRUE  "2 screen vertical 1:1"   \
		FALSE "2 screen vertical 16:5"  \
		FALSE "2 sceeen horizontal 1:1" \
		FALSE "3 screen vertical left 1:1:1" )
	case "$ans" in
	"1 screen")                     $0 -1; ;;
	"2 screen vertical 1:1")        $0 -2v; ;;
	"2 screen vertical 16:5")       $0 -2v_16:5; ;;
	"2 sceeen horizontal 1:1")      $0 -2h; ;;
	"3 screen vertical left 1:1:1") $0 -3vl; ;;
	esac
	;;
-debug)
	DEBUG=true
	. $0 "${2:-}"
	printWinsInfo winsinfo
	declare -p destinations
	printWinsInfo winsgoal
	declare -p borderinfo
	;;
-[0-9]*)
	populateWinsInfo
	populateDestinations ${1#-}
	pairWinsWithDestinations
	setWinsGoal
	;;
*)
	usage
	;;
esac
