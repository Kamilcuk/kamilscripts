#!/bin/bash
# Written by Kamil Cukrowski (C) 2017
# All rights reserved. 
#
################################ globals ###############################
set -euo pipefail

DEBUG=${DEBUG:-false}

################################### functions ##################################

debug_decl() {
	if $DEBUG; then
		debug() { echo "DEBUG: $*" >&2 ; }
	else
		debug() { :; }
	fi
}
debug_decl
error() { echo "ERROR:" "$@" >&2; }
fatal() { echo "FATAL:${FUNCNAME[1]}:" "$@" >&2; exit 1; }
assert() { if ! eval "$1"; then local expr; expr=$1; shift; fatal "assertion '${expr}' failed:" "$@"; fi; }

#################################

# cronDayCalcNext
# Parameters: MaxEpochTime Day Month WeekDay Year
# Returns: 0 if success, otherwise error
# Stdout: epoch times of events, otherwise error description
#
# The "Day Month WeekDay Year" format is just like cron's:
# * * * *
# | | | | 
# | | | +-- Year              (range: 1900-3000)
# | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
# | +------ Month of the Year (range: 01-12)
# +-------- Day of the Month  (range: 01-31)
# MaxEpochTime limits calculations to maximum MaxEpochTime seconds value
# If MaxEpochTime=0 then calculations are not limited
# If Year is omitted, it is assumed to be '*', so on
cronDayCalcNext() {
	local weekdayNameToInt_var=""
	isWeekdayName() {
		local name
		name=$1
		if [ -z "${weekdayNameToInt_var:-}" ]; then
			if ! weekdayNameToInt_var=$(seq 7 | xargs -I{} date --date='1-1-{}' +'%a {}'$'\n''%A {}'); then return 1; fi
		fi
		grep -q "^${name} " <<<"$weekdayNameToInt_var"
	}
	weekdayNameToInt() {
		local name tmp
		name=$1
		if [ -z "${weekdayNameToInt_var:-}" ]; then
			if ! weekdayNameToInt_var=$(seq 7 | xargs -I{} date --date='1-1-{}' +'%a {}'$'\n''%A {}'); then return 1; fi
		fi
		if ! tmp=$(grep "^${name} " <<<"$weekdayNameToInt_var"); then return 1; fi;
		cut -d' ' -f2 <<<"$tmp"
	}
	local monthNameToInt_var=""
	isMonthName() {
		local name
		name=$1
		if [ -z "${monthNameToInt_var:-}" ]; then
			if ! monthNameToInt_var=$(seq 12 | xargs -I{} date --date='1-{}-1' +'%b {}'$'\n''%B {}'); then return 1; fi
		fi
		grep -q "^${name} " <<<"$monthNameToInt_var"
	}
	monthNameToInt() {
		local name tmp
		name=$1
		if [ -z "${monthNameToInt_var:-}" ]; then
			if ! monthNameToInt_var=$(seq 12 | xargs -I{} date --date='1-{}-1' +'%b {}'$'\n''%B {}'); then return 1; fi
		fi
		if ! tmp=$(grep "^${name} " <<<"$monthNameToInt_var"); then return 1; fi
		cut -d' ' -f2 <<<"$tmp"
	}
	getNextWeekday() { date --date="${next_year}-${next_month}-${next_day}" +%u; }
	preParseCron() {
		case "$1" in
		''|\*) return; ;;
		*) ;;	
		esac
		# split on '/'
		local numcron divisor
		IFS='/' read -r numcron divisor <<<"$1"
		# parse divisor
		if [ "$divisor" == '*' ]; then
			divisor=""
		elif [ -n "$divisor" ]; then
			divisor=$((divisor))
		fi
		# catch empty and astericts
		case "$numcron" in
		''|*\**)
			echo "$divisor"
			return
			;;
		*)
			# divisor is first
			echo "$divisor"
			# split cron on ','
			numcron=${numcron//,/ }
			# expand lists if any
			for i in $numcron; do
				case "$i" in
				[0-9]*-[0-9]*) # numer1-number2 - list of numbers between number1 to number2
					local start stop
					IFS='-' read -r start stop <<<"$i"
					start=$((10#$start))
					stop=$((10#$stop))
					seq "$start" "$stop"
					;;
				[0-9]*) # single number
					i=$((10#$i));
					echo "$i"
					;;
				*[a-zA-Z]*)
					if isWeekdayName "$i"; then
						weekdayNameToInt "$i"
					elif isMonthName "$i"; then
						monthNameToInt "$i"
					else
						fatal "parsing cron value: '$i'"
					fi
					;;
				*)
					fatal "parsing cron value: '$i'"
					;;
				esac
			done
			;;
		esac
		echo
	}
	equalEntry() {
		if [ -n "$2" ]; then
			if (( $1 % $2 != 0 )); then
				return 1;
			fi
		fi
		if [ -z "$3" ]; then
			return 0;
		fi
		if grep -q -x "$1" <<<"$3"; then
			return 0
		fi
		return 1
	}

	local tmp next_inc

	# load input
	local maxepochtime cron_day cron_month cron_weekday cron_year 
	read -r maxepochtime cron_day cron_month cron_weekday cron_year <<<"$@"
	debug "cronDayCalcNext input | ${cron_day}-${cron_month}-${cron_year}-${cron_weekday} ${maxepochtime} "

	# load nexts
	tmp=$(date "+%s %_Y %_m %_d")
	local next_sec next_year next_month next_day
	read -r next_sec next_year next_month next_day <<<"$tmp"
	debug "cronDayCalcNext nexts | ${next_day}-${next_month}-${next_year} ${next_sec}"

	# parse input values
	local cron_day_divisor cron_day_nums
	local cron_month_divisor cron_month_nums
	local cron_year_divisor cron_year_nums
	local cron_weekday_divisor cron_weekday_nums
	for i in cron_day cron_weekday cron_month cron_year; do
		if ! tmp=$(preParseCron "${!i}"); then
			fatal "parsing cron value for $i=\"${!i}\""
		fi
		declare "${i}=$tmp"
		declare "${i}_divisor=$(echo "$tmp" | head -n1)"
		declare "${i}_nums=$(echo "$tmp" | tail -n +2)"
	done

	debug "cronDayCalcNext parsed | <<EOF |${cron_day}|${cron_month}|${cron_year}|${cron_weekday}| EOF"


	# handle bigger current year
	if [ -n "$cron_year" ] && (( next_year > cron_year )); then
		# this event will never occur
		return
	fi

	# if maxepochtime is null, then it's zero, otherwise its a number
	if [ -z "$maxepochtime" ]; then
		maxepochtime=0
	else
		if (( "$maxepochtime" != "$maxepochtime" )) 2>/dev/null; then
			echo "ERROR: maxepochtime=$maxepochtime is not a number!"
			return 3;
		fi
	fi

	while (( next_sec < maxepochtime )); do
		if ! equalEntry "$next_year" "$cron_year_divisor" "$cron_year_nums"; then
			next_month=1
			next_day=1
			next_inc=year
		elif ! equalEntry "$next_month" "$cron_month_divisor" "$cron_month_nums"; then
  			next_day=1
  			next_inc=month
	  	elif ! equalEntry "$next_day" "$cron_day_divisor" "$cron_day_nums" ||
	  		! equalEntry "$(getNextWeekday)" "$cron_weekday_divisor" "$cron_weekday_nums"; then
			next_inc=day
  		else
  			# success, date found
  			debug "cronDayCalcNext success |$cron_year|$cron_month|$cron_day|$cron_weekday| C= $next_year-$next_month-$next_day"
			echo "$next_sec" # output!
			# and find next date
			next_inc=day
  		fi

  		tmp=$(date --date="${next_year}-${next_month}-${next_day} ${next_inc}" "+%s %_Y %_m %_d";)
		read -r next_sec next_year next_month next_day <<<"$tmp"
	done
}

calcEventTimeDesc() {
	local diff day lat miesiecy
	diff=$1
	day=$((3600*24))
	lat=$((        diff    / (day*365)))
	miesiecy=$(( ( diff - lat*day*365 )      / (day*60)))
	dni=$((      ( diff - lat*day*365 -miesiecy*day*60 ) / day ))
	if (( lat == 0 && miesiecy == 0 )); then
		if (( dni == 0 )); then
			echo -n "Dzisiaj"
			return
		elif (( dni == 1 )); then
		 	echo -n "Jutro"
			return
		fi
	fi
	echo -n "Za"
	case "$lat" in
	0) ;;
	1)     echo -n " 1 rok"; ;;
	2|3|4) echo -n " 2 lata"; ;;
	*)     echo -n " $lat lat"; ;;
	esac
	case "$miesiecy" in
	0) ;;
	1)     echo -n " miesiąc"; ;;
	2|3|4) echo -n " 2 miesiące"; ;;
	*)     echo -n " $miesiecy miesięcy"; ;;
	esac
	case "$dni" in
	0) ;;
	1)     echo -n " dzień"; ;;
	*)     echo -n " $dni dni"; ;;
	esac
}

swietaStale() {
	cat <<EOF
01 01 | Nowy Rok
06 01 | Trzech Kroli
01 05 | Świeto Pracy
03 05 | Świeto Konstytucji 3 Maja
15 08 | Świeto Wojska Polskiego
01 11 | Wszystkich Swietych
11 11 | Swieto Niepodleglosci
25 12 | Boze Narodzenie(dzien pierwszy)
26 12 | Boze Narodzenie(dzien drugi)
EOF
}

swietaRuchome() {
	## wygenerowane za pomocą:
	## https://pl.wikisource.org/wiki/Tablice_%C5%9Bwi%C4%85t_ruchomych
	## head -n1 /tmp/1 | tr '\t' '\n' | { read -r empty; read -r empty; i=1; while read -r swieto; do i=$((i+2)); cat /tmp/1 | tail -n +2 | awk '{print $1,"/",$'"$((i+1))"',"/",$'"${i}"'}' | sed -e 's/stycznia/1/' -e 's/lutego/2/' -e 's/marca/3/' -e 's/kwietnia/4/' -e 's/maja/5/' -e 's/czerwca/6/' -e 's/lipca/6/' -e 's/ //g' -e 's/\*//' | while read line; do echo "| $(date --date="$line" +"%F") | $swieto"; done; done; } > /tmp/3
	## for i in $(seq 1 100); do echo -n "checkCat $((i+2000)) "; cat qqrememberrc | grep "^| 2$(printf %03d $i)" | while read -r event; do eventtime=$(eval "echo \"$(echo "$event" | cut -d'|' -f2)\""); eventepochtime=$(date --date="$eventtime" +%s); echo -n "$eventepochtime "; done; echo; done > /tmp/4
	## output is | epoch timestamp | description
	local startsec stopsec names
	# params
	startsec=$1
	stopsec=$2
	# get current year number
	startYear=$(date "--date=@${startsec}" +%Y)
	# get the next year number after untilfrom
	stopYear=$(date "--date=@$((stopsec+3600*24*365))" +%Y)
	assert "(( startYear <= stopYear ))"
	# nazwy świąt
	names="Tłusty czwartek
Ostatki
Popielec
Niedziela Palmowa
Niedziela Wielkanocna
Wniebowstąpienie
Zesłanie Ducha Świętego
Boże Ciało"
	
	{
		while read -r YEAR rest; do
			if (( YEAR > startYear )); then
				break
			fi
		done
		while read -r YEAR rest; do
			if (( YEAR > stopYear )); then
				break;
			fi
			paste -d'|' <(tr ' ' '\n' <<<"$rest") <(echo "$names")	
		done
	} <<EOF # YEAR tłusty czw   ostatki   popielec    palmowa   wielkanoc  wniebowst  zesłanie  boże ciało
2001  982796400  983228400  983314800  986680800  987285600  990655200  991519200  992469600 
2002 1013036400 1013468400 1013554800 1016924400 1017529200 1020895200 1021759200 1022709600 
2003 1046300400 1046732400 1046818800 1050184800 1050789600 1054159200 1055023200 1055973600 
2004 1077145200 1077577200 1077663600 1081029600 1081634400 1085263200 1085868000 1086818400 
2005 1107385200 1107817200 1107903600 1111273200 1111878000 1115503200 1116108000 1117058400 
2006 1140649200 1141081200 1141167600 1144533600 1145138400 1148767200 1149372000 1150322400 
2007 1171494000 1171926000 1172012400 1175378400 1175983200 1179612000 1180216800 1181167200 
2008 1201734000 1202166000 1202252400 1205622000 1206226800 1209852000 1210456800 1211407200 
2009 1234998000 1235430000 1235516400 1238882400 1239487200 1243116000 1243720800 1244671200 
2010 1265842800 1266274800 1266361200 1269730800 1270332000 1273960800 1274565600 1275516000 
2011 1299106800 1299538800 1299625200 1302991200 1303596000 1307224800 1307829600 1308780000 
2012 1329346800 1329778800 1329865200 1333231200 1333836000 1337464800 1338069600 1339020000 
2013 1360191600 1360623600 1360710000 1364079600 1364684400 1368309600 1368914400 1369864800 
2014 1393455600 1393887600 1393974000 1397340000 1397944800 1401573600 1402178400 1403128800 
2015 1423695600 1424127600 1424214000 1427583600 1428184800 1431813600 1432418400 1433368800 
2016 1454540400 1454972400 1455058800 1458428400 1459033200 1462658400 1463263200 1464213600 
2017 1487804400 1488236400 1488322800 1491688800 1492293600 1495922400 1496527200 1497477600 
2018 1518044400 1518476400 1518562800 1521932400 1522533600 1526162400 1526767200 1527717600 
2019 1551308400 1551740400 1551826800 1555192800 1555797600 1559426400 1560031200 1560981600 
2020 1582153200 1582585200 1582671600 1586037600 1586642400 1590271200 1590876000 1591826400 
2021 1612998000 1613430000 1613516400 1616886000 1617487200 1621116000 1621720800 1622671200 
2022 1645657200 1646089200 1646175600 1649541600 1650146400 1653775200 1654380000 1655330400 
2023 1676502000 1676934000 1677020400 1680386400 1680991200 1684620000 1685224800 1686175200 
2024 1707346800 1707778800 1707865200 1711234800 1711839600 1715464800 1716069600 1717020000 
2025 1740610800 1741042800 1741129200 1744495200 1745100000 1748728800 1749333600 1750284000 
2026 1770850800 1771282800 1771369200 1774738800 1775340000 1778968800 1779573600 1780524000 
2027 1801695600 1802127600 1802214000 1805583600 1806188400 1809813600 1810418400 1811368800 
2028 1834959600 1835391600 1835478000 1838844000 1839448800 1843077600 1843682400 1844632800 
2029 1865199600 1865631600 1865718000 1869087600 1869688800 1873317600 1873922400 1874872800 
2030 1898463600 1898895600 1898982000 1902348000 1902952800 1906581600 1907186400 1908136800 
2031 1929308400 1929740400 1929826800 1933192800 1933797600 1937426400 1938031200 1938981600 
2032 1959548400 1959980400 1960066800 1963436400 1964041200 1967666400 1968271200 1969221600 
2033 1992812400 1993244400 1993330800 1996696800 1997301600 2000930400 2001535200 2002485600 
2034 2023657200 2024089200 2024175600 2027541600 2028146400 2031775200 2032380000 2033330400 
2035 2053897200 2054329200 2054415600 2057785200 2058390000 2062015200 2062620000 2063570400 
2036 2087161200 2087593200 2087679600 2091045600 2091650400 2095279200 2095884000 2096834400 
2037 2118006000 2118438000 2118524400 2121894000 2122495200 2126124000 2126728800 2127679200 
2038 2151270000 2151702000 2151788400 2155154400 2155759200 2159388000 2159992800 2160943200 
2039 2181510000 2181942000 2182028400 2185394400 2185999200 2189628000 2190232800 2191183200 
2040 2212354800 2212786800 2212873200 2216242800 2216844000 2220472800 2221077600 2222028000 
2041 2245618800 2246050800 2246137200 2249503200 2250108000 2253736800 2254341600 2255292000 
2042 2275858800 2276290800 2276377200 2279746800 2280348000 2283976800 2284581600 2285532000 
2043 2306703600 2307135600 2307222000 2310591600 2311196400 2314821600 2315426400 2316376800 
2044 2339967600 2340399600 2340486000 2343852000 2344456800 2348085600 2348690400 2349640800 
2045 2370812400 2371244400 2371330800 2374696800 2375301600 2378930400 2379535200 2380485600 
2046 2401052400 2401484400 2401570800 2404940400 2405545200 2409170400 2409775200 2410725600 
2047 2434316400 2434748400 2434834800 2438200800 2438805600 2442434400 2443039200 2443989600 
2048 2465161200 2465593200 2465679600 2469049200 2469650400 2473279200 2473884000 2474834400 
2049 2497820400 2498252400 2498338800 2501704800 2502309600 2505938400 2506543200 2507493600 
2050 2528665200 2529097200 2529183600 2532549600 2533154400 2536783200 2537388000 2538338400 
2051 2559510000 2559942000 2560028400 2563398000 2563999200 2567628000 2568232800 2569183200 
2052 2592774000 2593206000 2593292400 2596658400 2597263200 2600892000 2601496800 2602447200 
2053 2623014000 2623446000 2623532400 2626902000 2627503200 2631132000 2631736800 2632687200 
2054 2653858800 2654290800 2654377200 2657746800 2658351600 2661976800 2662581600 2663532000 
2055 2687122800 2687554800 2687641200 2691007200 2691612000 2695240800 2695845600 2696796000 
2056 2717362800 2717794800 2717881200 2721250800 2721852000 2725480800 2726085600 2727036000 
2057 2750626800 2751058800 2751145200 2754511200 2755116000 2758744800 2759349600 2760300000 
2058 2781471600 2781903600 2781990000 2785356000 2785960800 2789589600 2790194400 2791144800 
2059 2811711600 2812143600 2812230000 2815599600 2816204400 2819829600 2820434400 2821384800 
2060 2844975600 2845407600 2845494000 2848860000 2849464800 2853093600 2853698400 2854648800 
2061 2875820400 2876252400 2876338800 2879704800 2880309600 2883938400 2884543200 2885493600 
2062 2906060400 2906492400 2906578800 2909948400 2910553200 2914178400 2914783200 2915733600 
2063 2939324400 2939756400 2939842800 2943208800 2943813600 2947442400 2948047200 2948997600 
2064 2970169200 2970601200 2970687600 2974057200 2974658400 2978287200 2978892000 2979842400 
2065 3001014000 3001446000 3001532400 3004902000 3005506800 3009132000 3009736800 3010687200 
2066 3033673200 3034105200 3034191600 3037557600 3038162400 3041791200 3042396000 3043346400 
2067 3064518000 3064950000 3065036400 3068406000 3069007200 3072636000 3073240800 3074191200 
2068 3097782000 3098214000 3098300400 3101666400 3102271200 3105900000 3106504800 3107455200 
2069 3128626800 3129058800 3129145200 3132511200 3133116000 3136744800 3137349600 3138300000 
2070 3158866800 3159298800 3159385200 3162754800 3163359600 3166984800 3167589600 3168540000 
2071 3192130800 3192562800 3192649200 3196015200 3196620000 3200248800 3200853600 3201804000 
2072 3222975600 3223407600 3223494000 3226860000 3227464800 3231093600 3231698400 3232648800 
2073 3253215600 3253647600 3253734000 3257103600 3257708400 3261333600 3261938400 3262888800 
2074 3286479600 3286911600 3286998000 3290364000 3290968800 3294597600 3295202400 3296152800 
2075 3317324400 3317756400 3317842800 3321212400 3321813600 3325442400 3326047200 3326997600 
2076 3349983600 3350415600 3350502000 3353868000 3354472800 3358101600 3358706400 3359656800 
2077 3380828400 3381260400 3381346800 3384712800 3385317600 3388946400 3389551200 3390501600 
2078 3411673200 3412105200 3412191600 3415561200 3416162400 3419791200 3420396000 3421346400 
2079 3444937200 3445369200 3445455600 3448821600 3449426400 3453055200 3453660000 3454610400 
2080 3475177200 3475609200 3475695600 3479065200 3479666400 3483295200 3483900000 3484850400 
2081 3506022000 3506454000 3506540400 3509910000 3510514800 3514140000 3514744800 3515695200 
2082 3539286000 3539718000 3539804400 3543170400 3543775200 3547404000 3548008800 3548959200 
2083 3569526000 3569958000 3570044400 3573414000 3574015200 3577644000 3578248800 3579199200 
2084 3600370800 3600802800 3600889200 3604258800 3604863600 3608488800 3609093600 3610044000 
2085 3633634800 3634066800 3634153200 3637519200 3638124000 3641752800 3642357600 3643308000 
2086 3663874800 3664306800 3664393200 3667762800 3668367600 3671992800 3672597600 3673548000 
2087 3697138800 3697570800 3697657200 3701023200 3701628000 3705256800 3705861600 3706812000 
2088 3727983600 3728415600 3728502000 3731868000 3732472800 3736101600 3736706400 3737656800 
2089 3758828400 3759260400 3759346800 3762716400 3763317600 3766946400 3767551200 3768501600 
2090 3791487600 3791919600 3792006000 3795372000 3795976800 3799605600 3800210400 3801160800 
2091 3822332400 3822764400 3822850800 3826216800 3826821600 3830450400 3831055200 3832005600 
2092 3853177200 3853609200 3853695600 3857065200 3857670000 3861295200 3861900000 3862850400 
2093 3885836400 3886268400 3886354800 3889720800 3890325600 3893954400 3894559200 3895509600 
2094 3916681200 3917113200 3917199600 3920569200 3921170400 3924799200 3925404000 3926354400 
2095 3949945200 3950377200 3950463600 3953829600 3954434400 3958063200 3958668000 3959618400 
2096 3980790000 3981222000 3981308400 3984674400 3985279200 3988908000 3989512800 3990463200 
2097 4011030000 4011462000 4011548400 4014918000 4015522800 4019148000 4019752800 4020703200 
2098 4044294000 4044726000 4044812400 4048178400 4048783200 4052412000 4053016800 4053967200 
2099 4075138800 4075570800 4075657200 4079023200 4079628000 4083256800 4083861600 4084812000 
2100 4105378800 4105810800 4105897200 4109266800 4109871600 4113496800 4114101600 4115052000 
EOF
}

#######################################

parseEvent() {
	local now untilfrom eventepochtime eventtime description tmp tmp2
	now=$1
	untilfrom=$2
	shift 2
	IFS='|' read -r eventtime eventdesc <<<"$@"

	debug "eventtime=\"${eventtime}\" eventdesc=\"$eventdesc\""

	# jesli jest jedna licza wieksza od 31, wtedy jest to epoch timestamp
	cnt=$( wc -w <<<"$eventtime" )
	if (( eventtime == eventtime )) 2>/dev/null && (( cnt == 1 && eventtime > 31 )); then
		eventepochtimes=$eventtime
	elif (( cnt >= 1 && cnt <= 4 )); then
		eventepochtimes=$(cronDayCalcNext "$untilfrom" "$eventtime")
	else
		fatal "parseEvent eventtime='$eventtime' cnt='$cnt' *=$*"
	fi

	for eventepochtime in $eventepochtimes; do
		if (( eventepochtime >= now && eventepochtime < untilfrom )); then
			# get description
			description=$( sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<<"$eventdesc" )
			tmp=$(date --date="@$eventepochtime" +%F)
			tmp2=$(( eventepochtime - now ))
			tmp2=$(calcEventTimeDesc "$tmp2")
			echo "$tmp | $tmp2: ${description}"
		fi
	done
}

usageExampleConfig() {
	cat <<EOF
# command to execute after the action, defaults to 'cat', is parsed via /bin/bash shell
# input from stdin ( this may be used for Command Injection )
COMMAND='cat | head -n10' # parsed until bash
COMMAND='cat'
# get dates from now until ( now + \$UNTIL )
# ex. '1 week' '2 days'
UNTIL='1 month'
SWIETA=true # laduj daty swiat do roku 2100

# | * * * * | Description
# | | | | | | |
# | | | | | | +- Evnet description, may contain any characters except newline
# | | | | | +--- Mandatory sign '|'
# | | | | +----- Year              (range: 1900-3000)
# | | | +------- Day of the Week   (range: 1-7, 1 standing for Monday)
# | | +--------- Month of the Year (range: 01-12)
# | +----------- Day of the Month  (range: 01-31)
# +------------- Mandatory sign '|' 
| 15 | Oplata czynsz kazdego 15 miesiaca
| *  *  $(date +%u) | Zajecia WF co $(date +%A)
| *  *  $(date --date=day +%u) | Zajecia WF co $(date --date=day +%A)
| *  *  $(date --date="2 days" +%u) | Zajecia WF co $(date --date="2 days" +%A)
| *  *  $(date --date="10 days" +%u) | Zajecia WF co $(date --date="10 days" +%A)
| $(date "+%d %m") | Dzisiaj: $(date)
| $(( $(date +%s) + 3600*24 )) | Jutro: $(date --date="@$(( $(date +%s) + 3600*24 ))")
| $(( $(date +%s) + 10*3600*24 )) | Za 10 dni: $(date --date="@$(( $(date +%s) + 10*3600*24 ))")
| /2 | Co drugi dzien
| */3 | Co trzeci dzien
| 5,10,20   | W 5,10,20 dzien miesiaca
| 1-10,20/5 | W 5,10,20 dzien miesiaca
| /5 /2 | W dzien podzielny przez 5 każdego podzielnego przez 2 miesiaca
| * $(date +%b) | '* $(date +%b)'
| * $(date +%B) | '* $(date +%B)'
| * $(date -d +1days +"%d %b") | '* $(date -d +1days +"%d %b")'
| * * $(date +%u) * | '* * * $(date +%u)'
| * * $(date +%a) * | '* * * $(date +"%a")'
| * * $(date +%A) * | '* * * $(date +"%A")'
EOF
}

usage() {
	cat <<"EOFUSAGE"
Usage:
    qqremember [-c <config>] [-S] [-u <UNTIL>]
    qqremember -h
    qqremember -E
    qqremember selftest

Options:
    -c <config>      - specify path to config file (default: ~/.config/qqremember.conf)
    -h               - show this text and exit
    -u <UNTIL>       - override UNTIL paramter in config file
    -C <COMAMND>     - override COMMAND parameter in config file
    -S [true|false]  - ładuj daty świąt w polsce od roku 2000 do roku 2100 (default: true)
                       daty pobrane z https://pl.wikisource.org/wiki/Tablice_%C5%9Bwi%C4%85t_ruchomych
    -E               - wypisz przykłądowy plik configuracyjny i zakończ program

Usage examples:
    qqremember

Author: Kamil Cukrowski <kamilcukrowski_at_gmail_dot_com> (c) 2017 Version 0.1.1

EOFUSAGE
}

#############################

parseBool() {
	declare -g "$1"
	case "$2" in 
		true|false) declare -g "$1=$2"; ;; 
		*) error "Invalid option $2"; usage; exit 1 ; ;;
	esac
}

##############################


############################## main #####################################

if ! ARGS=$(getopt -n "qqremember" -o ":c:dhu:C:S:P:E" -- "$@"); then
	error "parsing arguments.";
	exit 1;
fi
eval set -- "$ARGS"
CONFIG=${CONFIG:-~/.config/qqremember.conf} 
SWIETA=true COMMAND=cat PARALLEL=true
while true; do
	case "$1" in
	-c) 
		CONFIG=$2; 
		# shellcheck disable=2016
		assert '[ -r "$CONFIG" ]' "Config ${CONFIG} not found or not readable"
		shift
		;;
	-d) DEBUG=true; debug_decl; ;;
	-h) usage; exit; ;;
	-u) UNTIL=$2; shift; ;;
	-C) COMMAND=$2; shift; ;;
	-S) parseBool SWIETA "$2"; shift; ;;
	-P) parseBool PARALLEL "$2"; shift; ;;
	-E) usageExampleConfig; exit; ;;
	--) shift; break; ;;
	*) error "getopt internal error"; usage; exit 1; ;;
	esac
	shift;
done

# load configuration
configcontent=$(grep -v "[[:space:]]*#" "$CONFIG")
eval "$(grep -v -e "^|" <<<"$configcontent")"

if [ "$#" -ne 0 ]; then
	if (( $# == 1 )) && [[ "$1" == selftest ]]; then
		# shellcheck disable=2046,2086
		exec time bash $(if $DEBUG;then echo "-x";fi;) $0 -c <($0 -E) -P false -u '2 years'
		exit
	fi
	usage;
	exit 1;
fi

## sanity
for var in CONFIG SWIETA PARALLEL COMMAND UNTIL configcontent; do
	readonly "$var"
	if ! echo "${!var}" >/dev/null; then
		fatal "Error exanding $var"
	fi
	debug "$var=\"${!var}\""
done

## generate lines with descritions from events dates before period
{
	stopsec=$(date --date="$UNTIL" +%s)
	startsec=$(date --date="00:00:00" +%s)
	debug "stopsec=\"$stopsec\"=\"$( date --date="@$stopsec" )\""
	debug "startsec=\"$startsec\""
	events=$(grep "^|" <<<"$configcontent" | sed 's/^|//')
	if $SWIETA; then
		events+="$(swietaStale)"
		events+="$(swietaRuchome "$startsec" "$stopsec")";
	fi
	lines=$(
		set -euo pipefail; export SHELLOPTS
		if $PARALLEL; then
			export -f parseEvent error debug fatal cronDayCalcNext calcEventTimeDesc
			xargs -L1 -P10 bash -c 'parseEvent "$@"' -- "$startsec" "$stopsec"
		else
			while read -r line; do 
				parseEvent "$startsec" "$stopsec" "$line"; 
			done
		fi <<<"$events"
	)
	lines=$(echo "$lines" | sort)
	debug "lines=\"$lines\""$'\n'
}

# dont send if empty lines
#if [ -z "$lines" ]; then
#	debug "lines empty"
#	exit
#fi

## use command with "lines" as standart input
# shellcheck disable=2046,2086
/bin/bash $(if $DEBUG;then echo "-x";fi;) -c "$COMMAND" <<<"$lines"

wait
debug "SUCCESS!"

