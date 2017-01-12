#!/bin/bash
#++++++++++++++++
# Monitor Switch
#
# Moves currently focused window from one monitor to the other.
# Designed for a system with two monitors.
# Script should be triggered using a keyboard shortcut.
# If the window is maximized it should remain maximized after being moved.
# If the window is not maximized it should retain its current size, unless
# height is too large for the destination monitor, when it will be trimmed.
#++++++++++++++++

DEBUG=false

# resolution of left monitor
w_l_monitor=1280
h_l_monitor=1024
# resolution of right monitor
w_r_monitor=1280
h_r_monitor=1024

# window title bar height and weight
h_tbar=22
w_tbar=1

# focus on active window
window=`xdotool getactivewindow`
inf=`xwininfo -id $window`
IFS=$' ';

#when window is xfdesktop dont do anything

$DEBUG && echo ---- INFORMATION ----- && echo $inf
[[ $(echo $inf | grep 'xwininfo: Window id:' | sed 's/xwininfo: Window id: 0x[0-9]* //') == '"Desktop"' ]] && exit

# get active window size and position
x=$(echo $inf | grep "Absolute upper-left X" | awk '{print $4}')
y=$(echo $inf | grep "Absolute upper-left Y" | awk '{print $4}')
w=$(echo $inf | grep "Width" | awk '{print $2}')
h=$(echo $inf | grep "Height" | awk '{print $2}')
$debug && echo ------ position x y w h $x $y $w $h

# window fullscreen
if [ "$h" -eq "1024" ] && [ "$w" -eq "1280" ]; then
  wmctrl -r:ACTIVE: -b remove,fullscreen
  fullscreen=1
else
  fullscreen=0
fi
# window maximalize 
## it can be also fullscreeen AND maximalize, need to know that :)
if [ "$w" -eq "1280" ]; then
  wmctrl -r:ACTIVE: -b remove,maximized_vert,maximized_horz
  maximalize=1
else
  maximalize=0
fi
# window on left monitor
if [ "$x" -lt "$w_l_monitor" ]; then
  new_x=$[$x+$w_l_monitor-$w_tbar]
  new_y=$[$y-$h_tbar]
  xdotool windowmove $window $new_x $new_y

# window on right monitor
else
  new_x=$[$x-$w_l_monitor-$w_tbar]
  new_y=$[$y-$h_tbar]
  xdotool windowmove $window $new_x $new_y
fi

if [ "$maximalize" -eq "1" ]; then
  wmctrl -r:ACTIVE: -b add,maximized_vert,maximized_horz
fi
if [ "$fullscreen" -eq "1" ]; then
  wmctrl -r:ACTIVE: -b add,fullscreen
fi

