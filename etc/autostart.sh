#!/bin/bash
# run from ~/.config/autorun/kamilscripts.desktop

if (($# == 1)) && [[ "$1" = "desktopentry" ]]; then
	log=~/.cache/xsession-errors
	if [[ -e "$log" ]]; then
		mv "$log" "$log".old
	fi
	exec 1>>"$log" 2>&1
fi

###############################################################################

log() {
	printf "%s\n" "$*"
}

run() {
	log "+" "$@" >&2
	"$@"
}

L_command_exists() {
	command -v "$1" >/dev/null 2>&1
}

verbosed=()

verbosed_on() {
	for i in "$@"; do
		eval "
			$i() {
				log "+" \"$i\" \"\$@\" >&2
				command \"$i\" \"\$@\"
			}
		"
	done
	verbosed+=("$i")
}

verbosed_off() {
	if (($# == 0)); then
		verbosed_off "${verbosed[@]}"
	else
		unset -f "$@"
		for i in "$@"; do
			for j in "${!verbosed[@]}"; do 
				if [[ "$i" == "${verbosed[j]}" ]]; then
					unset verbosed[j]
				fi
			done
		done
	fi
}

autostart_log() {
	log ":::::: kamilscripts autostart.sh:" "$@"
}

_xfconf-query() {
	( set -x
	xfconf-query "$@"
	)
}

###############################################################################

autostart_log "begin"

( set -x
xset b off
xset r rate 250 30
xset mouse 1/1 1
setxkbmap pl
)

case "${XDG_CURRENT_DESKTOP,,}" in
(xfce)
	_xfconf-query -c keyboard-layout -p /Default/XkbLayout                       -s pl,us
	_xfconf-query -c keyboard-layout -p /Default/XkbVariant                      -s ,
	_xfconf-query -c keyboards       -p /Default/KeyRepeat                       -s true
	_xfconf-query -c keyboards       -p /Default/KeyRepeat/Delay                 -s 250
	_xfconf-query -c keyboards       -p /Default/KeyRepeat/Rate                  -s 30
	_xfconf-query -c pointers        -p /USB_Optical_Mouse/Acceleration          -s 1.000000
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/file-icons/show-home      -s true
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/file-icons/show-removable -s false
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/show-hidden-files         -s false
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/show-thumbnails           -s true
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/show-tooltips             -s true
	_xfconf-query -c xfce4-desktop   -p /desktop-icons/single-click              -s false
	_xfconf-query -c xfwm4           -p /general/mousewheel_rollup               -s false
	_xfconf-query -c xfwm4           -p /general/theme                           -s Adapta-Nokto
	_xfconf-query -c xfwm4           -p /general/tile_on_move                    -s true
	_xfconf-query -c xfwm4           -p /general/workspace_count                 -s 4
	_xfconf-query -c xfwm4           -p /general/wrap_windows                    -s false
	_xfconf-query -c xsettings       -p /Net/CursorBlinkTime                     -s 1200
	_xfconf-query -c xsettings       -p /Net/IconThemeName                       -s Adwaita
	_xfconf-query -c xsettings       -p /Net/ThemeName                           -s Adwaita-dark
	if pulseaudioplug=$(xfconf-query -c xfce4-panel -lv | awk '$2 == "pulseaudio"{print $1}') &&
			[[ -n "$pulseaudioplug" ]]; then
		# https://forum.xfce.org/viewtopic.php?id=12082
		__xfconf-query -c xfce4-panel -p "$pulseaudioplug"/volume-step --create -t int -s 2
	fi
	if hash fc-list 2>/dev/null >/dev/null && [[ -n "$(fc-list 'LiterationMono Nerd Font')" ]]; then
		_xfconf-query -c xfwm4           -p /general/title_font                      -s 'LiterationSans Nerd Font Bold 9'
		_xfconf-query -c xsettings       -p /Gtk/FontName                            -s 'LiterationSans Nerd Font 10'
		_xfconf-query -c xsettings       -p /Gtk/MonospaceFontName                   -s 'LiterationMono Nerd Font 10'
	else
		_xfconf-query -c xfwm4           -p /general/title_font                      -s 'Liberation Sans Bold 9'
		_xfconf-query -c xsettings       -p /Gtk/FontName                            -s 'Liberation Sans 10'
		_xfconf-query -c xsettings       -p /Gtk/MonospaceFontName                   -s 'Liberation Mono 10'
	fi
	;;
(*)
	autostart_log "unknown XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP}"
	;;
esac

if L_command_exists xbindkeys && ! pgrep xbindkeys >/dev/null; then
	run xbindkeys -p
fi

for i in ~/.config/kamilscripts/kamilscripts/etc/autostart/*.sh; do
	if [[ -e "$i" ]]; then
		autostart_log "running user script: $i"
		. "$i"
	fi
done

autostart_log "END"

