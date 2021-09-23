#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

############################## globals #########################

DEBUG=${DEBUG:-false}
OVERWRITE=${OVERWRITE:-false}
ONEPATH=${ONEPATH:-false}
DONTARCHIVE=${DONTARCHIVE:-false}
DONTCREATELISTING=${DONTCREATELISTING:-false}

myname="$(basename "$0")"
logfile="./$myname.log"

############################## functions #######################


usage() {
	cat <<EOF
./qqbackup_archive_folder.sh <dir>
	Skrypt archiwizuje foldery/pliki w danym folderze.
	Każdy plik/folder jest archiwizowany do osobnego archiwum.
	Każde archiwum posiada swój log, zawierający listing plików w archiwum.
	Defaultowo pliki/foldery już zarchiwizowane są pomijane.

./qqbackup_archive_folder.sh <dir> <path>
	Skrypt archiwizuje tylko podaną ścieżkę w danym katalogu.

	Zatem co robi ten skrypt:
1. Wypisuje co zostanie zrobione i pyta o potwiedzenie (zawsze).
2. Każdy plik/folder w podanym katalogu archiwizowany jest za pomocą:
	env BZIP2=-8 tar -cvjSf <path>.tar.bz2 <path>
3. Do każdego archiwum tworzony jest plik zawierający listing plików w tym archiwum:
	tar -tf <path>.tar.bz2 > <path>.tar.bz2.info.txt
4. Log wszystkich działań jest zapisywany w ./qqbackup_archive_folder.sh.log
5. Wypisywana jest komenda umożliwiająca usunięcie skompresowanych katalogów.

Parametry środowiskowe:
	OVERWRITE=[true|false] - jeśli false, pliki już zarchiwizowane są pomijane
		( to znaczy takie dla których już istnieje plik .tar.bz2 w katalogu )
		default value: false
	DEBUG=[true|false] - default value: false

	Autor:
Kamil Cukrowski

	License:
"THE BEER-WARE LICENSE" (Revision 42):
Kamil Cukrowski wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return.

EOF
}

date() {
	command date '+%Y-%m-%dT%H:%M:%S'
}

logerror() { echo "$(date) ERR:  $*" | tee -a "$logfile"; }
loglog()   { echo "$(date) LOG:  $*" | tee -a "$logfile"; }
logwarn()  { echo "$(date) WARN: $*" | tee -a "$logfile"; }

findpaths() 
{
	find . -mindepth 1 -maxdepth 1 \
		-name qqbackup_archive_folder.sh\* -prune -o \
		-name \*.tar.bz2 -prune -o \
		-name \*.tar.bz2.info.txt -prune -o \
		-print
}

test_this_script() {
	errors=""
	mkdir /tmp/10
	cd /tmp/10
	echo 1123 >'1'
	mkdir -p 2 3 3/4
	echo 2123 > 2/5
	echo 314142 > 3/6
	echo 123713 > 3/4/7
	echo 'y' | ./qqbackup_archive_folder.sh /tmp/10
	for i in 1 2 3; do
		for j in $i $i.tar.bz2 $i.tar.bz2.info.txt; do
			if [ -e $j ]; then
				errors+="ERROR: $j not found!!"
			fi
		done
	done
	if [ ! -e ./qqbackup_archive_folder.sh.log ]; then
		errors+="ERROR: ./qqbackup_archive_folder.sh.log not found!!"
	fi
	echo "$errors"
}

print_info() {
	# 'paths' passed as environment
	local archive 
	local uncompressedsize uncompressedsizehuman 
	local   compressedsize   compressedsizehuman
	local compressionratio spacesavings
	echo "Info about compression ratio: https://en.wikipedia.org/wiki/Data_compression_ratio "
	{
	echo "Uncompressed Path|Compressed Archive|Uncompressed|Compressed|Compression Ratio[%]|Space Savings[%]"
	for path in "${paths[@]}"; do
		path="${path##./}" ## remove leading './'
		archive="${path/%/.tar.bz2}"
		if [ ! -e "$archive" ]; then
			continue;
		fi
		uncompressedsize="$(du -s "$path"    | awk '{print $1}' )"
		uncompressedsizehuman="$(du -hs "$path"    | awk '{print $1}' )"
		compressedsize="$(du -s "$archive" | awk '{print $1}' )"
		compressedsizehuman="$(du -hs "$archive" | awk '{print $1}' )"
		compressionratio=$(( uncompressedsize*100/compressedsize ))
		spacesavings=$(( 100-(compressedsize*100/uncompressedsize) ))
		echo "$path|$archive|$uncompressedsizehuman|$compressedsizehuman|$compressionratio|$spacesavings"
	done
	} | column -t -s'|'
}

############################### main ###################################

### ########## main - check input

echo "START: $myname $*"
if [ "$DEBUG" != "true" ] && [ "$DEBUG" != "false" ]; then echo "Bad DEBUG value \"$DEBUG\"."; exit 3; fi
if $DEBUG; then set -x; fi
if [ "$myname" != "qqbackup_archive_folder.sh" ]; then echo "Wrong executable filename - [ \"$myname\" != \"qqbackup_archive_folder.sh\" ] returned false."; exit 3; fi
if [ "$OVERWRITE" != "true" ] && [ "$OVERWRITE" != "false" ]; then echo "Bad OVERWRITE value \"$OVERWRITE\"."; exit 3; fi	
if [ $# -lt 1 ]; then usage; echo "Wrong number of arguments."; exit 1; fi
mydir="${1}"
if [ ! -d "$mydir" ]; then usage; echo "Directory $mydir does not exists!"; exit 1; fi
if [ ! -w "$mydir" ]; then usage; echo "Directory $mydir is not writable!"; exit 1; fi
if [ $# -eq 2 ]; then
	ONEPATH=true
	paths=( "${2}" )
fi

################### main - find paths to archive
cd "$mydir"
echo;
echo "==== Finding paths ==="
if ! $ONEPATH; then
	echo "Finding paths with function:"
	declare -f findpaths
	echo "Finding now..."
	tmp=$(findpaths)
	mapfile -t paths <<<"$tmp"
	echo "Paths found:"
	for i in "${paths[@]}"; do echo "$i"; done
	if ! $OVERWRITE; then
		echo "Removing already archived paths."
		temppaths=()
		for path in "${paths[@]}"; do
			if [ -e "$path.tar.bz2" ]; then
				echo " ^ Removing $path, cause $path.tar.bz2 alreasy exists."
			else
				temppaths+=( "$path" )
			fi
		done
		paths=( "${temppaths[@]}" )
	else
		temppaths=()
		for path in "${paths[@]}"; do
			if [ -e "$path.tar.bz2" ]; then
				temppaths+=( "$path.tar.bz2" )
			fi
		done
		echo "This will overwrite files: ${temppaths[*]}"
	fi
else
	paths=( "$(basename "$(readlink -f "${paths[0]}")" )" )
	echo "No finding - runniing only for one path: ${paths[*]}"

fi
echo;

########### check paths
if [ "${#paths[*]}" -eq 0 ]; then
	echo "No paths to archive found."
	exit 3
fi
for path in "${paths[@]}"; do
	if [ ! -e "$path" ]; then
		echo "ERROR $path does not exists!"
	fi
done

##################### main -  user confirmation

echo "==== confirmation ===="
echo;
echo " Logi zostaną dopisane do pliku $logfile"
echo " Zarchiwizowane zostaną następujące ścieżki:"
echo " Utworzone/nadpisane zostaną następujące archiwa i listing plików:"
{
	echo "Ścieżka|Archiwum|Listing plików"
	for path in "${paths[@]}"; do
		echo "$path|$path.tar.bz2|$path.tar.bz2.info.txt"
	done
} | column -t -s'|'
echo;
echo "Przeczytaj na górze, od 'confirmation' w dół. Czy jestęś pewien, że chcesz kontynuować? [y|n]"
read -r -n 1 a
echo;
if [ "$a" != 'y' ]; then exit 2; fi
echo;
echo "OK - STARTING!"
echo;

######################## main - backup + log + archive

outputtars=( "${paths[@]/%/.tar.bz2}" )

loglog "==========================================================================="
loglog "RUN: $0 $*"

if ! $DONTARCHIVE; then
	loglog "==== Archiving"
	for path in "${paths[@]}"; do
		loglog "env BZIP2=-8 tar -cvjSf ${path}.tar.bz2 ${path} | tee -a $logfile"
		env BZIP2=-8 tar -cvjSf "${path}.tar.bz2" "${path}" | tee -a "$logfile"
	done
fi
if ! $DONTCREATELISTING; then
	loglog "=== Listing archives to infofile for every archive"
	for path in "${outputtars[@]}"; do
		infofile="$path.info.txt"
		loglog "tar -tf ${path} > $infofile"
		{
			echo "==== File ${path} created by $myname"
			echo "==== Listing of ${path} created with:"
			echo "==== tar -tf \"${path}\" >> \"$infofile\""
			tar -tf "${path}" 
		} > "$infofile"
	done
fi
	
loglog "EXIT: $0 $*"
echo =========================== DONE ==========================a

################ main - ending notice
echo;
echo "Logi działań zostały dopisane do $logfile"
echo;
echo "Zarchiwizowane następujące ścieżki:"
echo "Utworzone/nadpisane zostały następujące archiwa i listing plików:"
{
	echo "Ścieżka|Archiwum|Listing plików"
	for i in "${paths[@]}"; do
		echo "$path|$path.tar.bz2|$path.tar.bz2.info.txt"
	done
} | column -t -s'|'
echo;
echo "Informacja na temat jakości kompresji każdej ścieżki:"
print_info
echo;
echo "Teraz możesz usunąć zarchiwizowane ścieżki poleceniem:"
echo;
echo "rm -vr ""$(for path in "${paths[@]}"; do echo -n "'$path' "; done)"
echo;

