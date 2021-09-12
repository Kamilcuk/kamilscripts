#!/bin/sh
# kamilscripts ~/.xinitrc
# Copied from /etc/lightdm/Xsession

log=~/.cache/xsession-errors
if [ -e "$log" ]; then
	mv "$log" "$log".old
fi
exec 1>>"$log" 2>&1

echo "::: Running kamilscripts X session wrapper"

# Load profile
for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/.xprofile"; do
    if [ -f "$file" ]; then
        echo "Loading profile from $file";
        . "$file"
    fi
done


# Run all system xinitrc shell scripts
xinitdir="/etc/X11/xinit/xinitrc.d"
if [ -d "$xinitdir" ]; then
    for script in $xinitdir/*; do
        echo "Loading xinit script $script"
        if [ -x "$script" -a ! -d "$script" ]; then
            . "$script"
        fi
    done
fi

# Run user xsession shell script
script="$HOME/.xsession"
if [ -x "$script" -a ! -d "$script" ]; then
    echo "Loading xsession script $script"
    . "$script"
fi

set -- startxfce4

echo "::: kamilscripts X session wrapper complete, running session $*"

exec "$@"


