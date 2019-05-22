#!/bin/bash
set -euo pipefail

dest=$(readlink -f "$1")
mkdir -p $(dirname "$dest")
cat <<EOF |
<!DOCTYPE html>
<html>
<body>
<p>This is kamcuk/archlinux-repo repo hosted on gitlab pages.</p>
<p>See <a href="http://gitlab.com/Kamcuk/kamilscripts">here</a> for sources of this site.</p>
<p>This site was generated on $(date -u -R).</p>
<p>Files links:</p>
<br>
<br>
$(find * -print | sort | xargs -n1 -P0 -I{} bash -c "echo '<a href={}>{}</a><br>'")
</body>
</html>
EOF
tee "$dest"

