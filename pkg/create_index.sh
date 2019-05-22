#!/bin/bash
set -xeuo pipefail

dest=$(readlink -f "$1")
now=$(date -u -R)

mkdir -p "$dest"
files=$(cd "$dest" && find . -printf "%P\n" | sort |
	xargs -n1 -I{} printf '<a href={}>{}</a><br>')
tee "$dest"/index.html <<EOF
<!DOCTYPE html>
<html>
<body>
<p>This is Kamcuk/kamilscripts repo hosted on gitlab pages.</p>
<p>See <a href="http://gitlab.com/Kamcuk/kamilscripts">here</a> for sources of this site.</p>
<p>This site was generated on $now.</p>
<p>Files links:</p>
<br>
<br>
$files
</body>
</html>
EOF

