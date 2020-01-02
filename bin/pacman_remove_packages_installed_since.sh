#!/bin/bash -ue

DEBUG=${DEBUG:-false}

if [ $# -lt 1 ]; then
	cat << EOF
Usage examples:
	$0 today
	$0 yesterday
	$0 last week
	$0 last saturday
	$0 last month
EOF
	exit
fi

seconds=$(date --date="$*" +%s)
pacmanlogsFilterDateInstalled() {
	local num year mon day hour min year2 mon2 day2 hour2 min2 pkg tmp1 tmp2
	read year mon day hour min < <(date --date="@$seconds" '+%Y %m %d %H %M')
	$DEBUG && echo Packages since: $year-$mon-$day $hour:$min >&2
	tmp1=$(mktemp)
	tmp2=$(mktemp)
	trap 'rm -f $tmp1 $tmp2' EXIT
	cat /var/log/pacman.log | grep '\] installed ' | grep "^\[" | \
		tee >(cut -d' ' -f5 > $tmp1) | cut -d' ' -f1,2 | tr -d '[|]' | tr '\-|:' ' ' > $tmp2
	{
	for i in year mon day hour min; do
		while read -r year2 mon2 day2 hour2 min2 pkg; do
			$DEBUG && echo -$year-$mon-$day-$hour-$min-$year2-$mon2-$day2-$hour2-$min2- >&2
			eval a=\$${i}2
			eval b=\$$i
			if   [ "$a" -eq "$b" ]; then
				break
			elif [ "$a" -gt "$b" ]; then
				break 2
			fi
		done
	done 
	cat | cut -d' ' -f6
	}< <(paste -d' ' "$tmp2" "$tmp1")
	rm -f "$tmp1" "$tmp2"
	trap '' EXIT
}

ins=$( pacmanlogsFilterDateInstalled | sort -u )
insexp=$(comm -12 <(echo "$ins") <(pacman -Qqe) )
remov=$( comm -23 <(echo "$ins") <(pacman -Qq ) )
still=$( comm -12 <(echo "$ins") <(pacman -Qq ) )
{
echo "Packages since \"$*\"# $(date --date="@$seconds" '+%Y-%m-%d %H:%M'):00"
echo "Packages explicitly installed# "$insexp
echo "Packages installed# "$ins
echo "Packages already removed# "$remov
echo "Packages still installed# "$still
} | column '-s#' -t -o:
echo
echo "+ pacman --confirm -R "$still
pacman --confirm -R $still

