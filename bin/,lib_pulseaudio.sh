#!/bin/bash

,pulseaudio_list_1() {
	# tableoutput is a comma separated list of lowercase fields
	# jsonuotput is a bool if we should output json
	pactl list | awk \
		-v tableoutput=_what,_num,_name,_description \
		-v jsonoutput=0 \
	'
		# props array stores all output globally with comma separated values

		function cur_clear() {
			# stores all output
			for (i in cur) {
				delete cur[i]
			}
			# delete temporary variables
			i=""
			section=""
			subsection=""
			what=""
			num=""
			val=""
		}

		function strappend(str, str2) {
			return str (length(str)?", ": "") str2
		}

		function jsonesc(str) {
			str = gensub(/([\\"])/, "\\\\\\1", "g", str) 
			str = gensub(/\t/, "\\\\t", "g", str)
			return str
		}

		BEGIN{
			OFS="\t"
			if (tableoutput) {
				print gensub(",", "\t", "g", tableoutput)
			}
		}

		# read the lines "something #<number>"
		/^[^ ]*.* #[0-9]*$/{
			cur["_what"] = what = gensub(" *#.*", "", "1", $0);
			cur["_num"]  = num  = gensub(".*#",   "", "1", $0);
		}

		# all other lines start with a leading tab
		length(what) && /^\t[^\t]/{
			# balance is special.. :(
			if (/^\t *balance/) {
				section = $1
				val = $2
			} else {
				section = gensub("^[\t ]*([^:]*)[ \t]*:.*$", "\\1", "1", tolower($0))
				section = gensub("^[\t ]*", "", "g", section)
				val = gensub("^\t[^:]*: *", "", "1", $0)
			}

			if (length(val) == 0) {
				subsection = section
			} else {
				subsection = ""
				props[what, num, section] = val
				cur[section] = val
			}
		}

		# sometimes theres a subsection - handle that and put it in dot separated values into output
		length(what) && length(subsection) && /^\t\t[^ ]* = /{
			section = gensub(/^[\t ]*([^ ]*).*$/, "\\1", "g", $0)
			section = subsection "." section
			val = gensub(/^[^=]*= /, "", "g", $0)
			props[what, num, section] = val
			cur[section] = val
		}

		# set custom fields
		length(what) {
			if (section == "name" || (length(cur["_name"]) == 0 && section ~ "\\.name$")) {
				cur["_name"] = cur[section]
			}
			if (section == "description" || (length(cur["_description"]) == 0 && section ~ "\\.description$")) {
				cur["_description"] = cur[section]
			}
		}
		
		function output() {
			if (jsonoutput) {
				print "{ \"what\": \""what"\", \"num\": \""num"\""
				for (i in cur) {
					print ", \""jsonesc(i)"\": \""jsonesc(cur[i])"\""
				}
				print "}"
			} else if (tableoutput) {
				split(tableoutput, c, ",")
				for (i=1;i<=length(c);++i) {
					printf "%s%s", cur[c[i]], i==length(c)?"":OFS
				}
				printf "\n"
			}
			cur_clear();
		}

		# empty lines ends the section
		/^$/{ output(); }
		END{
			output();
			if (0) for (i in props) {
				print i, props[i]
			}
		}
	'
}

,pulseaudio_filter_1() {
	if ((!$#)); then
		cat <<EOF
Usage: ,pulseaudio_filter_1 <what> <id> <name> <description>

Filter the pactl list output using glob expression on all fields.
Then output only id number. Empty glob expressions are interpreted
as a star * - match everything.

Example:

,lib_pulseaudio.sh ,pulseaudio_filter_1 'Sink' '' '' 'Built-in Audio Analog Stereo'

EOF
		exit 1
	fi
	,pulseaudio_list_1 |
	while IFS=$'\t' read -r a b c d; do
		case "$a" in (${1:-*})
		case "$b" in (${2:-*})
		case "$c" in (${3:-*})
		case "$d" in (${4:-*})
			printf "%s\n" "$b"
		esac
		esac
		esac
		esac
	done
}

,pulseaudio_filter_2() {
	,pulseaudio_filter_1 "$1" '' "$2" "$3"
}

. ,lib_lib "$BASH_SOURCE" ',pulseaudio_' "$@"

