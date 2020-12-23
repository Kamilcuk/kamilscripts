#!/bin/bash
set -euo pipefail

export LANGUAGE=pl_PL

. ,bash_autotranslate.sh

notify() {
	notify-send -i "$1" "todoist" "$2"
}

dryrun=""
if (($#)) && [[ "$1" = "-n" ]]; then
	shift
	dryrun="DRYRUN: "
	run() { echo "DRYRUN:" "$@"; }
else
	run() { "$@"; }
fi

looperrormsg() {
	errormsg+="${errormsg:+$'\n'}$1"
	again=true
}

labels=$(,todoist-cli labels)
projects=$(,todoist-cli projects)
readonly labels projects

while "${again:-true}"; do
	again=false

	if (($#)) && [[ -n "$1" ]]; then
		if [[ -n "${txt:-}" ]]; then exit 1; fi
		txt=$1
		shift
	else
		txt=$(
			text="${errormsg:+$"Error"": $errormsg"$'\n\n'}"
			text+=$"Add a new task to todoist with name?"$'\n\n'
			text+=$"Available @labels"": $(cut -d' ' -f2- <<<"$labels" | paste -sd' ')"$'\n\n'
			text+=$"Available #projects"": $(cut -d' ' -f2- <<<"$projects" | paste -sd ' ')"$'\n\n'
			text=$(fmt -u -s -w 70 <<<"$text")$'\n'
			zenity --entry \
			--entry-text="${savetxt:-}" \
			--title="todoist" \
			--text="$text"
		)
	fi
	savetxt="$txt"
	errormsg=""

	addlabels=""
	addlabelsprint=()
	addproject=""
	addprojectprint=""
	priority=""

	if txtlabels=$(<<<"$txt" grep -Pwo "@\K[^[:space:]]*"); then
		txtlabels=$(sort -u <<<"$txtlabels")
		for i in $txtlabels; do
			if ! tmp=$(fzf -q "$i" -1 -0 <<<"$labels"); then
				looperrormsg $"The label could not be found"": $i"$'\n'$"Labels"": $(<<<"$labels" cut -d' ' -f2- | paste -sd' ')"
				break
			fi
			IFS=' ' read -r a b <<<"$tmp"
			addlabelsprint+=("$b")
			addlabels="${addlabels:+$addlabels,}$a"
		done
	fi


	if txtprojects=$(<<<"$txt" grep -Pwo "#\K[^[:space:]]*"); then
		for i in $txtprojects; do
			if [[ -n "$addproject" ]]; then
				looperrormsg $"Given more then one project"": $(paste -sd' ' <<<"$txtprojects")"
				break
			fi
			if ! tmp=$(fzf -q "$i" -1 -0 <<<"$projects"); then
				looperrormsg $"Project not found"": $i"$'\n'$"Projects"": $(<<<"$projects" cut -d' ' -f2- | paste -sd' ')"
				break
			fi
			IFS=' ' read -r addproject addprojectprint <<<"$tmp"
		done
	fi

	if priorities=$(<<<"$txt" grep -Pwo "p\K[0-9]"); then
		priority=$(tail -n1 <<<"$priorities")
		if [ "$priority" -lt 1 ] || [ "$priority" -gt 4 ]; then
			looperrormsg $"Invalid priority number, it has to be p1, p2, p3 or p4"": $priorities"
		fi
	fi

	if [[ -n "$errormsg" ]]; then
		notify dialog-error "$errormsg"
	fi

	if "$again"; then
		continue
	fi

	for ((i=0;i<2;++i)); do
		txt=$(sed 's/\(^\|[[:space:]]\)[#@][^[:space:]]*[[:space:]]*/\1/g' <<<"$txt")
	done
	mesg=$"task""."$'\n'
	mesg+=$"With name"": $txt"

	cmd=(todoist add)
	if [[ -n "${addlabels:-}" ]]; then
		mesg+=$'\n'$"To project"": ${addprojectprint[*]}"
		cmd+=(-L "$addlabels")
	fi
	if [[ -n "${addproject:-}" ]]; then
		mesg+=$'\n'$"With labels"": ${addlabelsprint[*]}"
		cmd+=(-P "$addproject")
	fi
	if [[ -n "${priority:-}" ]]; then
		mesg+=$'\n'$"With priority"": $priority"
		cmd+=(-p "$priority")
	fi

	cmd+=("$txt")

	if run "${cmd[@]}"; then
		notify-send -i appointment-new "todoist" "${dryrun}"$"Added"": $mesg"
	else
		notify-send -i dialog-error "todoist" "${dryrun}"$"Problem with adding task"" $mesg"$'\n'$"Command"": ${cmd[*]}"
		looperrormsg $"Problem with adding task"
	fi
done

exit

: <<EOF
#### bash_autotranslate pl_PL
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Last-Translator: Automatically generated\n"
"Language-Team: none\n"
"Language: pl\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=3; plural=(n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);\n"

#: bin/,todoist_dodaj_nowe_zadanie.sh:39
msgid "Error"
msgstr "Błąd"

#: bin/,todoist_dodaj_nowe_zadanie.sh:38
msgid "Add a new task to todoist with name?"
msgstr "Dodaj nowe zadanie o nazwie?"

#: bin/,todoist_dodaj_nowe_zadanie.sh:38
msgid "Available @labels"
msgstr "Dostępne etykiety"

#: bin/,todoist_dodaj_nowe_zadanie.sh:38
msgid "Available #projects"
msgstr "Dostępne projekty"

#: bin/,todoist_dodaj_nowe_zadanie.sh:63
msgid "The label could not be found"
msgstr "Etykieta nie znaleziona"

#: bin/,todoist_dodaj_nowe_zadanie.sh:63
msgid "Labels"
msgstr "Etykiety"

#: bin/,todoist_dodaj_nowe_zadanie.sh:76
msgid "Given more then one project"
msgstr "Podano więcej niż jeden projekt"

#: bin/,todoist_dodaj_nowe_zadanie.sh:80
msgid "Project not found"
msgstr "Nie ma takiego projektu"

#: bin/,todoist_dodaj_nowe_zadanie.sh:80
msgid "Projects"
msgstr "Projekty"

#: bin/,todoist_dodaj_nowe_zadanie.sh:90
msgid "Invalid priority number, it has to be p1, p2, p3 or p4"
msgstr "Nieprawidłowy numer priorytetu, musi być p1, p2, p3 lub p4"

#: bin/,todoist_dodaj_nowe_zadanie.sh:105
msgid "task"
msgstr "zadanie"

#: bin/,todoist_dodaj_nowe_zadanie.sh:106
msgid "With name"
msgstr "O nazwie"

#: bin/,todoist_dodaj_nowe_zadanie.sh:110
msgid "To project"
msgstr "Do projektu"

#: bin/,todoist_dodaj_nowe_zadanie.sh:114
msgid "With labels"
msgstr "Z etykietą"

#: bin/,todoist_dodaj_nowe_zadanie.sh:118
msgid "With priority"
msgstr "Z priorytetem"

#: bin/,todoist_dodaj_nowe_zadanie.sh:125
msgid "Added"
msgstr "Dodano"

#: bin/,todoist_dodaj_nowe_zadanie.sh:127
#: bin/,todoist_dodaj_nowe_zadanie.sh:128
msgid "Problem with adding task"
msgstr "Problem z dodaniej zadania"

#: bin/,todoist_dodaj_nowe_zadanie.sh:127
msgid "Command"
msgstr "Polecenie"

#### bash_autotranslate END
EOF

