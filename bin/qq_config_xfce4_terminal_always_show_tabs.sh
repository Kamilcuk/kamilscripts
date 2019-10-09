#!/bin/bash
set -xeuo pipefail
sed -i -e 's/^MiscAlwaysShowTabs=.*/MiscAlwaysShowTabs=TRUE/' "${XDG_CONFIG_HOME:-$HOME/.config}"/xfce4/terminal/terminalrc
cat "${XDG_CONFIG_HOME:-$HOME/.config}"/xfce4/terminal/terminalrc

