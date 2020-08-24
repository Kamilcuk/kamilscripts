#!/bin/bash
set -euo pipefail

name=$(basename "$0")

# Events File
ef="/tmp/.$name"

usage() {
	cat <<EOF
Usage: $name [options] events...

Changes active window position to position specified by events.
Runs in a semi server/client mode where events are listened
for specified timeout before executing the action.
The communication is done via file: $ef
The script is meant to be used with xbindkeys with following bindings:
--- SNIP ---
",magic_position_window.sh right"
  Mod4 + Right
",magic_position_window.sh up"
  Mod4 + Up
",magic_position_window.sh down"
  Mod4 + Down
",magic_position_window.sh left"
  Mod4 + Left
--- SNIP ---

Options:
	-h --help         Print this text and exit
	-t --timeout=INT  Set server timeout, default 0.05
	   --debug        Enable logging messages

Available events:
    up down right left  

Examples:
    $name up right

Events actions:
    up down right left
	     - Move and resize window to the specified half of the screen
	up+right down+left right+up left+up
	     - Move and resize window to the specified qourter of the screen
	left+right
	     - Move and resize window to fullscreen, use ctrl+F10
    up+down
	     - Move and resize window to the middle of the screen

Written by Kamil Cukrowski
Licensed jointly under Beerware License and MIT License.
EOF
}

# functions ###########################################

log() { if "${debug:-false}"; then echo "$name:" "$@"; fi; }
fatal() { echo "$name: error:" "$@" >&2; exit 1; }

notify_msgs=""
notify() {
	declare -g notify_msgs name activew

	log "notify: $*"
	local title
	title=
	if (($# == 2)); then
		title=$1
		shift
	fi
	notify_msgs+="$1"$'\n'
	local n
	n="$name.${activew:-}"
	org.freedesktop.Notifications.Notify.sh "$n" 0 "dialog-information" \
	"$notify_msgs$name" "${title:-$name}" "" "" 500 /tmp/.notifyval."$n" >/dev/null ||:
}

source "$(dirname "$(readlink -f "$0")")"/lib/,x_functions.sh

getPanelHeight() {
	# add more panels if needed
	local w
	if wmctrl -l -G | awk '$2 == -1 && $8 == "xfce4-panel" && NF == 8{ print $6; exit 1 }'; then
		fatal "${FUNCNAME[0]} - unknown panel - returning 20" >&2
	fi
}

getScreenGeometry() {
	#xwininfo -root | awk '/-geometry/{gsub(/+|x/," ");print $2,($3-'"$(getPanelHeight)"')}'  
	local tmp
	tmp=$(getPanelHeight)
	wmctrl -l -G | awk -v tmp="$tmp" '$2 == -1 && $8 == "Desktop"{ print $5,($6-tmp) }'
}

getBorderInfo() {
	,x_get_window_border_info "$@"
}

wmove() {
	declare -g activewname activew events
	notify "$activewname" "Moving $events ($1,$2,$3,$4)"
	local x y width height id
	id=$activew
	x=$1 y=$2 width=$3 height=$4
	tmp=$(getBorderInfo "$id")
	read -r bleft bright btop bbottom <<<"$tmp"
	# resize and move to specified position
    wmctrl -i -r $id -e 0,$x,$y,$((width-bleft-bright)),$((height-btop-bbottom))
    # unmaximize
    wmctrl -i -r $id -b remove,fullscreen
	wmctrl -i -r $id -b remove,maximized_vert
	wmctrl -i -r $id -b remove,maximized_horz
    # double resizing seem to be correcting strange behavior
    wmctrl -i -r $id -e 0,$x,$y,$((width-bleft-bright)),$((height-btop-bbottom))
}

wtogglefullscreen() {
	declare -g activew activewname
	local id
	id=$activew
	notify "$activewname" "Toggle maximized"
	wmctrl -i -r $id -b toggle,maximized_vert
	wmctrl -i -r $id -b toggle,maximized_horz
	# wmctrl -i -r $id -b toggle,fullscreen #,maximized_vert,maximized_horz
}

action() {
	local events
	events=$1

	local activew activewname
	activew=$(xdotool getactivewindow)
	activewname=$(xdotool getactivewindow getwindowname)

	local mx my tmp
	tmp=$(,x_get_window_monitor "$activew" | awk '{print $2,$3}')
	read -r mx my <<<"$tmp" # Monitor X, Monitor Y

	tmp=$(,x_get_xfce4_panel_info)
	read -r _ _ _ _ panelheight hiding <<<"$tmp"
	if ((!hiding)); then
		my=$((my - panelheight))
	fi

	local mxh myh  # Monitor X divided by 2, Monitor Y divided by 2
	mxh=$(( mx / 2 + !!(mx % 2) ))
	myh=$(( my / 2 + !!(my % 2) ))

	# Filter whisker menu from moving
	case "$activewname" in
	*"Whisker Menu"*) notify "Not moving whisker menu"; exit; ;;
	*) ;;
	esac

	case "$events" in
	up)         wmove 0    0    $mx  $myh; ;;
	down)       wmove 0    $myh $mx  $myh; ;;
	left)       wmove 0    0    $mxh $my ; ;;
	right)      wmove $mxh 0    $mxh $my ; ;;
	right+up)   wmove $mxh 0    $mxh $myh; ;;
	left+up)    wmove 0    0    $mxh $myh; ;;
	down+right) wmove $mxh $myh $mxh $myh; ;;
	down+left)  wmove 0    $myh $mxh $myh; ;;
	left+right) wtogglefullscreen; ;;
	down+up) wmove $((mxh/2)) $((myh/2)) $mxh $myh; ;;
	*) notify "Unknown events: $events"; ;;
	esac
}

server() {
	local timeout
	timeout="$1"

	log "Server starting timeout=$timeout"
	
	# exit after max 3 seconds
	( 
		trap_exit() {
			log "Removing $ef"
			rm -f "$ef"
		}
		trap trap_exit EXIT
		sleep "$timeout"
		sleep 0.5
	) &
	local child
	child=$!
	trap_exit() {
		kill "$child" 2>/dev/null
	}
	trap trap_exit EXIT

	# get events
	local events
	events=""
	while IFS= read -t "$timeout" -r line; do
		line="${line,,}" # lowercase
		case "$line" in
		up|down|right|left) events+="$line"$'\n'; ;;
		*) notify "Unknown message: $line" >&2; ;;
		esac
	done 0<>"$ef" <"$ef"

	events=$(echo -n "$events" | sort -u | paste -sd '+')
	if [[ -z "$events" ]]; then
		notify "no events"
		exit
	fi
	log "$events"

	# this causes to remove the eventsfile
	kill "$child"

	action "$events"
}

# main #################################################

args=$(getopt -n "$name" -o ht: -l help,timeout:,debug -- "$@")
eval set -- "$args"
server_timeout=0.1
debug=false
while (($#)); do
	case "$1" in
	-h|--help) usage; exit; ;;
	-t|--timeout) server_timeout=$2; shift; ;;
	--debug) debug=true; ;;
	--) shift; break; ;;
	esac
	shift
done

if (($# < 1)); then fatal "Wrong number of arguments, see $name --help"; fi

# check if fifo exists
# if it does, that means we are only a client, if it doesn't
# that means we have to run the server
{
	flock 9
	if [[ ! -e "$ef" ]]; then
		mkfifo "$ef"
		runserver=true
	else
		runserver=false
	fi
} 9<"$0"

if "$runserver"; then
	# server
	server "$server_timeout" &
fi

for i; do
	log "Sending $i to $ef"
	if ! [[ -p "$ef" ]]; then
		notify "$ef is not a fifo, removing it"
		rm "$ef"
		exit 1
	fi
	if ! timeout 1 echo "$i" >> "$ef"; then
		notify "Something wrong with the fifo, removing it"
		rm "$ef"
	fi
done
