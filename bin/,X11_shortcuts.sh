#!/bin/bash
set -euo pipefail

name="${BASH_SOURCE##*/}"

html-quote() {
  sed '
		s/\&/\&amp;/g
		s/</\&lt;/g
		s/>/\&gt;/g
	'
}

log() {
  echo "$name:" "$@"
}

fatal() {
  echo "$name: ERROR:" "$@" >&2
  exit 1
}

int_to_bool() {
  case "$1" in
  1) echo true ;;
  *) echo false ;;
  esac
}

movewindow() {
  if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
    qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Window to Desktop" "$1"
  else
    xdotool getactivewindow set_desktop_for_window "$(($1 - 1))"
  fi
}

xrun_usage() {
  cat <<EOF
Usage:
	$name [OPTIONS] <cmd>
	$name [OPTIONS] <text> <cmd>

Options:
	-i --icon   Add this icon to notifysend
	-h --help   Print this help and exit.

Written by Kamil Cukrowski
Licensed jointly under MIT License and Beerware License.
EOF
}

xrun() {
  args=$(getopt -n "$0-xrun" -o +i:h -l icon:,help -- "$@")
  eval set -- "$args"
  local icon=forward text
  while (($#)); do
    case "$1" in
    -i | --icon)
      icon="$2"
      shift
      ;;
    -h | --help)
      xrun_usage
      exit 1
      ;;
    --)
      shift
      break
      ;;
    *) fatal "error when parsing arugment: $1" ;;
    esac
    shift
  done
  if (($# > 2)); then fatal "Too many arguments"; fi
  if (($# >= 2)); then
    text=$1
    shift
  else
    text=""
  fi
  nohup bash -xc "$*" >/dev/null </dev/null 2>&1 &
  local text
  text="$(
    cat <<EOF
${text:+<big><b>    $(html-quote <<<"$text")</b></big>
}<small>Running: <tt>$(html-quote <<<"$*")</tt></small>
EOF
  )"
  KCDIR=~/.kamilscripts/
  local d
  d="$KCDIR/icons/$1.png"
  if [[ -e "$d" ]]; then
    icon="$d"
  fi

  if hash notify-send 2>/dev/null >/dev/null; then
    notify-send -u low -i "$icon" -t 2000 "xbindkeys" "$text"
  fi
}

###############################################################################

cmd+Mod4+F1() { movewindow 1; }
cmd+Mod4+F2() { movewindow 2; }
cmd+Mod4+F3() { movewindow 3; }
cmd+Mod4+F4() { movewindow 4; }
cmd+Mod4+F5() { movewindow 5; }
cmd+Mod4+F6() { movewindow 6; }
cmd+Mod4+F7() { movewindow 7; }

cmd+Mod4+a() { xrun geany; }
cmd+Mod4+shift+A() { xrun ,todoist_dodaj_nowe_zadanie.sh; }
cmd+Mod4+t() { xrun -itodoist todoist firefox --new-window 'https://todoist.com/app/'; }
# cmd+Mod4+s() { xrun subl; }
cmd+Mod4+f() { xrun "soffice --calc"; }
cmd+Mod4+c() {
  case "$HOSTNAME" in
  leonidas) xrun -i utilities-terminal konsole ;;
  ardalus) xrun "xfce4-terminal --geometry=126x34" ;;
  gorgo) xrun "xfce4-terminal --geometry=64x22" ;;
  *) xrun xfce4-terminal ;;
  esac
}

case "$HOSTNAME" in
leonidas)
  cmd+Mod4+equal() { xrun "soffice --calc /home/kamil/mnt/share/archive/moje_dokumenty/zestawienie.ods"; }
  cmd+Mod4+3() { xrun ",leonidas toggle_hdmi_mute"; }
  cmd+Mod4+4() { xrun ",xrandr_change_brightness.sh -0.1"; }
  cmd+Mod4+5() { xrun ",xrandr_change_brightness.sh +0.1"; }
  cmd+Mod4+F9() { xrun "pactl set-sink-mute   @DEFAULT_SINK@ toggle"; }
  cmd+Mod4+F10() { xrun "pactl set-sink-volume @DEFAULT_SINK@ -2%"; }
  cmd+Mod4+F11() { xrun "pactl set-sink-volume @DEFAULT_SINK@ +2%"; }
  cmd+Mod4+F12() { xrun ",leonidas toggle_hdmi_mute"; }
  ;;
*)
  cmd+Mod4+4() { xrun "xdotool keyup 4 keyup Super_L key XF86MonBrightnessDown keydown Super_L"; }
  cmd+Mod4+5() { xrun "xdotool keyup 5 keyup Super_L key XF86MonBrightnessUp   keydown Super_L"; }
  ;;
esac

Mod4+grave() { xrun "pactl set-sink-mute   @DEFAULT_SINK@ toggle"; }
cmd+Mod4+1() { xrun "pactl set-sink-volume @DEFAULT_SINK@ -2%"; }
cmd+Mod4+2() { xrun "pactl set-sink-volume @DEFAULT_SINK@ +2%"; }

case "$HOSTNAME" in
leonidas) ;;
*)
  cmd+Mod4+Right() { xrun ",magic_position_window.sh right"; }
  cmd+Mod4+Up() { xrun ",magic_position_window.sh up"; }
  cmd+Mod4+Down() { xrun ",magic_position_window.sh down"; }
  cmd+Mod4+Left() { xrun ",magic_position_window.sh left"; }
  ;;
esac

cmd+XF86Search() { xrun "-iorg.xfce.appfinder" "xfce4-appfinder"; }
cmd+XF86HomePage() { xrun "-ifirefox" "browser" "firefox"; }
cmd+XF86ScreenSaver() { xrun "-ixfsm-lock" "xflock4"; }
cmd+XF86Calculator() { xrun "-iorg.xfce.terminal" "xfce4-terminal -e \"bash -c \\\"echo Running bc calculator; bc\\\"\""; }
cmd+XF86Tools() { xrun "-ifirefox" "firefox https://open.fm/stacja/alt-pl https://open.spotify.com/search"; }
cmd+Mod4+n() { xrun -ifirefox browser firefox; }
cmd+Mod4+e() { xrun -ifolder_open File Explorer xdg-open ~; }
cmd+Mod4+w() {
  xrun -iemblem-mail email \
    "nohup birdtray -t >/dev/null </dev/null 2>&1"
  # xdotool search --onlyvisible --class --onlyvisible --limit 1 'BlueMail' windowquit || bluemail --in-process-gpu;
}
cmd+Mod4+m() { cmd+Mod4+w; }
cmd+XF86Mail() { cmd+Mod4+w; }

cmd+Mod4+d() { xrun -iteams teams; }
cmd+Mod4+s() { xrun -iteams teams; }

cmd+Control+Shift+Alt+Mod4+Mod5+Control_R() { xrun -ixfsm-suspend Suspend "sleep 0.5 && systemctl suspend"; }
cmd+Control+Shift+Mod2+Mod4+Mod5+Control_R() { cmd+Control+Shift+Alt+Mod4+Mod5+Control_R; }

cmd+Control+Escape() { xrun -ixfce4-whiskermenu xfce4-popup-whiskermenu; }

cmd+Mod4+r() { xrun "xdotool click --repeat 4 1"; }

###############################################################################

get_commands() {
  LC_ALL=C compgen -A function | LC_ALL=C sed -n "s/^${1:-cmd+}//p" | LC_ALL=C sort -u
}

mode_xbindkeys() {
  get_commands | while IFS= read -r line; do
    cat <<EOF
(xbindkey|'(${line//+/ })|"$0 \"$line\"")
EOF
  done | column -s'|' -o' ' -t
}

mode_help() {
  echo "Available builtins:"
  get_commands mode_ | sed 's/^/  /'
  echo "Available commands:"
  get_commands | sed 's/^/  /'
}

r() {
  echo "+ $*" >&2
  "$@"
}

addsc() {
  local key cmd
  key=$1
  cmd=$*
  echo kwriteconfig6 --file kglobalshortcutsrc --group AAA_kc \
    --key "$cmd" "$key,none,${cmd@Q}"
}

mode_kde() {
  get_commands | while IFS= read -r line; do
    addsc "$line" "$0 $line"
  done
}

###############################################################################

if (($# == 0)); then fatal "Argument missing. Call help."; fi
if (($# != 1)); then fatal "Too many arguments"; fi
if declare -f "mode_$1" 2>/dev/null 1>&2; then
  "mode_$1"
else
  "cmd+$1"
fi
