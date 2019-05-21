#!/bin/bash
set -ueo pipefail; export SHELLOPTS

DEBUG=${DEBUG:-false}

LOGLVL=2
log() { if [ "$1" -le "${LOGLVL:-2}" ]; then shift; echo "$@"; fi; }
debug() { $DEBUG && echo "$@" >&2 || true; }
gen1() { echo -n "<span class=\"mw-headline\" id=\"$1"; }
gen2() { echo -n "\">$1</span>"; }
gen3() { gen1 "$@"; gen2 "$@"; }
gen4() { gen1 "$1"; gen2 "$2"; }
getTypeSigned() { 
	case "$1" in
	*"$(gen1 Signed)"*"$(gen2 Signed)"*)
                debug "Signed $line"
                echo "signed=signed"
                ;;
        *"$(gen1 Unsigned)"*"$(gen2 Unsigned)"*)
                debug "Unsigned $line"
                echo "signed=unsigned"
                ;;
        *"$(gen3 Any)"*)
                debug "Any $line"
                echo "type=Any"
                ;;
	*"$(gen4 Both_i686_and_x86_64 "Both i686 and x86_64")"*)
                debug "Both $line"
                echo "type=Both_i686_and_x86_64"
                ;;
        *"$(gen4 i686_only "i686 only")"*)
                debug "i686 $line"
                echo "type=i686_only"
                ;;
        *"$(gen4 x86_64_only "x86_64 only")"*)
                debug "x86_64 $line"
                echo "type=x86_64_only"
                ;;
        esac
}

remove_html_tags() { 
	sed 's/<[^>]*>//g' | sed '/^$/d'
}

extract_between_tag() {
	local tag
	tag=$1
	while read -r line; do 
		log 5 "read 2 $line" >&2
		if [[ $line =~ '<'"$tag"'>' ]]; then 
				break;
		fi;
	done;
	tmp=$line
	while ! [[ $line =~ '</'"$tag"'>' ]] && read -r line; do 
		log 5 "read 3 $line" >&2
		tmp+=$'\n'"$line"
	done
	echo "$tmp"
}

sign_all_keys() {
		cat file | grep Key-ID | grep -v "Not\|repo" | awk '{print $3}' | xargs -n1 -I{} -- sudo bash -c 'echo pacman-key --recv-keys {}; echo pacman-key --finger {}; echo pacman-key --lsign-key {}'
}
# main #######################################################################

url="https://wiki.archlinux.org/index.php/unofficial_user_repositories"
file=/tmp/.unofficial_user_repositories

( set -x;
	curl -s -z "$file" -o "$file" "$url"
)

xmllint --html --xpath '//div[@class="mw-parser-output"]' "$file" \
| while read -r line; do
	log 5 "read $line"
	if   [[ $line =~ ^'<h2><span class="mw-headline" '.*igned ]]; then
		r_section=$(remove_html_tags <<<"$line")
		echo
		echo "# --------- $r_section ------------"
		echo
	elif [[ $line =~ ^'<h3><span class="mw-headline" ' ]]; then
		r_name=$(remove_html_tags <<<"$line")
		r_comment=$(extract_between_tag ul | remove_html_tags)
		r_server=$(extract_between_tag pre | remove_html_tags)

		echo "# $r_name"
		sed 's/^/#   /' <<<"$r_comment"
		echo "$r_server"
		if [ "$r_section" = "Unsigned" ]; then
			echo "SigLevel = PackageOptional"
		fi
		echo
	fi
done
