#!/bin/bash
set -ue
DEBUG=${DEBUG:-false}
DEBUG=true
url="https://wiki.archlinux.org/index.php/unofficial_user_repositories#youtube-dl"
file=/tmp/.unofficial_user_repositories


curl -sS -z "$file" -o "$file" "$url"

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

# main #######################################################################

prefile=$(xmllint --html --xpath '//div[@class="mw-parser-output"]' $file)
content=$(echo "$prefile" \
| sed -e 's/<li>/     \* /' -e '/^<[^>]*>$/d' \
	-e 's/<strong>/     /' -e 's/<p>/     /' \
	-e 's/<[^>]*>//g' \
	-e 's/\&lt;/</g;s/\&gt;/>/g;'  \
| sed -n -e '/^Any/,$p' | sed -n -e '/^<!--/q;p' \
| sed -e '/^[[:space:]]*$/d' -e '/^   [^ ]/{N;s/\n   [^ ]/ /;}' \
      -e 's/^\(\[\|Server\|#\)/     > \1/' \
| sed -e '
:a;/^     \* /{
	N; 
	/\n     \* /{ 
		h; s/\n.*//; p; g;
		s/.*\n//; ba;
	};
	s/\n       / /g;
}' \
      -e 's/^\([^ ].*\)/END_OF_SECTION\n\1/' \
| tail -n +2;
echo "END_OF_SECTION"
)


accumulator=""
IFS=''
while read -r line; do
	case "$line" in
	END_OF_SECTION)
		section="$accumulator"
		accumulator=""

		sectionname=$(echo "$section" | head -n1)
		section=$(echo "$section" | tail -n+2)
		case "$sectionname" in
		Any|x86_64)
			stype=$sectionname; 
			if [ -n "$section" ]; then
				echo
				echo "# Section $stype"
				echo "$section" | sed 's/^/#/'
				echo '#'
			fi
			;;
		Signed|Unsigned)
			ssigned=$sectionname;
			echo
			echo "# <=== Section: $stype $ssigned ==> ############################# "
			echo "# Section: $sectionname ######################### "
			echo "$section" | sed 's/^/#/'
			echo '#'
			;;
		*)
			if [ -z "$stype" -o -z "$ssigned" ]; then
				echo "ERROR [ -z "$stype" -o -z "$ssigned" ]" >&2a
				continue;
			fi
			conf=$(echo "$section" | sed -n -e '/^     > /s/^     > //p')
			if [ -z "$conf" ]; then
				continue;
			fi
			echo
			echo "# Name: $sectionname"
			echo "$section" | grep -v '^     > ' | sed 's/^[[:space:]]*/# /'
			echo "$conf"
			arch=x86_64
			repo=$(echo "$conf" | head -n1 | sed 's/\[//;s/\]//')
			url=$(echo "$section" | grep '^     > Server = ' | head -n1 | sed 's/.*= //')
			url=$(echo "$url"'/$repo.db' | sed -e 's/$arch/'"$arch"'/' -e 's/$repo/'"$repo"'/')
			echo $url
			CURLOPTS=""
			case "$repo" in archlinuxgr-any) CURLOPTS=-k; ;; esac
			url_head=$(curl $CURLOPTS --head "$url")
			last_modified=$(echo "$url_head" | grep -i '^last-modified: ' | sed 's/^[^:]*: //')
			last_modified=$(date --date="$last_modified" "+%F %T")
			echo "# repo last modified: $last_modified"
			;;
		esac

		;;
	*)
		accumulator+="$line"$'\n'
		;;
	esac
done <<<"$content"

