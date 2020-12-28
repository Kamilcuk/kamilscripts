#!/bin/bash
# run from ~/.config/autorun/kamilscripts.desktop

if (($#)) && [[ "$1" = "desktopentry" ]]; then
	# We are called from desktopentry - redirect stdout and stderr to xsession-errors
	exec 1>>~/.xsession-errors 2>&1
fi

log() {
	printf "%s\n" "$*"
}

run() {
	log "+" "$@" >&2
	"$@"
}

verbosed=()

verbosed_on() {
	for i in "$@"; do
eval "
	$i() {
		log "+" \"$i\" "\$@" >&2
		command \"$i\" "\$@"
	}
"
	done
	verbose+=("$i")
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

###############################################################################

autostart_log "begin"

( verbosed_on xset setxkbmap
xset b off
xset r rate 250 30
xset mouse 1/1 1
setxkbmap pl
)

case "${XDG_CURRENT_DESKTOP,,}" in
(xfce) ( verbosed_on xfconf-query
	xfconf-query -c xfwm4     -p /general/mousewheel_rollup      -s false
	xfconf-query -c xfwm4     -p /general/theme                  -s Adapta-Nokto
	xfconf-query -c xfwm4     -p /general/tile_on_move           -s true
	xfconf-query -c xfwm4     -p /general/title_font             -s 'Liberation Sans Bold 9'
	xfconf-query -c xfwm4     -p /general/workspace_count        -s 4
	xfconf-query -c xfwm4     -p /general/wrap_windows           -s false
	xfconf-query -c xfwm4     -p /general/wrap_windows           -s true
	xfconf-query -c pointers  -p /USB_Optical_Mouse/Acceleration -s 1.000000
	xfconf-query -c keyboards -p /Default/KeyRepeat              -s true
	xfconf-query -c keyboards -p /Default/KeyRepeat/Delay        -s 250
	xfconf-query -c keyboards -p /Default/KeyRepeat/Rate         -s 30
	xfconf-query -c xsettings -p /Gtk/FontName                   -s 'Liberation Sans 10'
	xfconf-query -c xsettings -p /Gtk/MonospaceFontName          -s 'Liberation Mono 10'
	xfconf-query -c xsettings -p /Net/CursorBlinkTime            -s 1200
	xfconf-query -c xsettings -p /Net/IconThemeName              -s Adwaita
	xfconf-query -c xsettings -p /Net/ThemeName                  -s Adwaita-dark
	); ;;
(*)
	autostart_log "unknown XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP}"
	;;
esac

if ! pgrep xbindkeys >/dev/null; then
	run bindkeys
fi

for i in ~/.config/kamilscripts/kamilscripts/etc/autostart/*.sh; do
	if [[ -e "$i" ]]; then
		autostart_log "running user script: $i"
		. "$i"
	fi
done

autostart_log "END"

