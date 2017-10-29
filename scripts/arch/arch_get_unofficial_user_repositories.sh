#!/bin/bash
set -ue
DEBUG=${DEBUG:-false}
DEBUG=true
url="https://wiki.archlinux.org/index.php/unofficial_user_repositories#youtube-dl"
file=/tmp/.unofficial_user_repositories

if [ ! -e "$file" ]; then
	curl -s "$url" > $file
fi

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

all=() # output
if true; then

type=""
signed=""
lasttype=""
lastsigned=""
num=0
while read line; do
	eval "$(getTypeSigned "$line")"
	if [[ -z "$type" && -z "$signed" ]]; then
		startnum=$num
	else
		if [[ "$type" != "$lasttype" || "$signed" != "$lastsigned" ]] ; then
			new="name=${lasttype}_$lastsigned start=$startnum stop=$num"
			all+=( "$new" )
			debug "new $new"
			lasttype=$type
			lastsigned=$signed
			startnum=$num
		fi
	fi
	num=$((num+1));
done <$file
new="name=${lasttype}_$lastsigned start=$startnum stop=$num"
all+=( "$new" )
debug "new $new"

fi

declare -p all
#declare -a all=([0]="name=_ start=207 stop=208" [1]="name=Any_ start=208 stop=211" [2]="name=Any_signed start=211 stop=261" [3]="name=Any_unsigned start=261 stop=269" [4]="name=Both_i686_and_x86_64_unsigned start=269 stop=272" [5]="name=Both_i686_and_x86_64_signed start=272 stop=446" [6]="name=Both_i686_and_x86_64_unsigned start=446 stop=552" [7]="name=i686_only_unsigned start=552 stop=553" [8]="name=i686_only_signed start=553 stop=564" [9]="name=i686_only_unsigned start=564 stop=594" [10]="name=x86_64_only_unsigned start=594 stop=595" [11]="name=x86_64_only_signed start=595 stop=794" [12]="name=x86_64_only_unsigned start=794 stop=1054")

for i in "${all[@]}"; do
	eval "$i"
	servers="$(sed -n "$start,$stop"p "$file" | grep -B1 "^Server = " | grep -v -x "^--" || true)"
	if [ -n "$servers" ]; then
		echo
		echo "# $name -------------------------------------------"
		echo "$servers"
	fi
done
