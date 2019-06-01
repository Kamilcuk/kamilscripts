#!/bin/bash
set -euo pipefail

f=/tmp/.cachefile

if [ ! -e "$f" ]; then
	curl -sS https://wiki.archlinux.org/index.php/Pacman/Tips_and_tricks -o "$f"
fi

remove_html_tags() {
	echo "$@" | sed -e 's/<[^>]*>//g'
}


out=$(cat /tmp/.cachefile | xmllint --html - | grep "mw-headline\|<pre>$ \|<p>")
out=$(echo "$out" | while read -r line; do
	l=$(remove_html_tags $line)
	case "$line" in
	"<h2>"*) h2=$l h3='' h4='' p=''; ;;
	"<h3>"*) h3=$l h4='' p=''; ;;
	"<h4>"*) h4=$l p=''; ;;
	"<p>"*)	p=$(tr -d '\n' <<<"$l"); ;;
	"<pre>"*) 
		l=${l##$ }
		#e=$(echo "$l" | recode -d html..ascii)
		e=$(echo "$l" | perl -MHTML::Entities -pe 'decode_entities($_);')
		e=$(echo "$e" | sed -e 's/repo_name/"$1"/g')
		echo "$h2@$h3@$h4@$p@$e";
		;;
	esac
done

)

# echo "$out"; exit;

echo "$out" | while IFS='@' read -r h2 h3 h4 p e; do
	case=$(echo -n "$h3 $h4" | tr ' ' '_')
	echo $'\t'"$case"
	echo $'\t\t'"$p"
done

echo;echo;echo

echo "$out" | while IFS='@' read -r h2 h3 h4 p e; do
	case=$(echo -n "$h3 $h4" | tr ' ' '_')
	echo "${case})"
	echo $'\t'"$e;"
	echo $'\t'";;"
done






