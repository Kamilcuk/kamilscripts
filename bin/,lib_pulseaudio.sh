#!/bin/bash

,pulseaudio_list_1() {
	,pulseaudio_list_2 "_what,_num,_name,_description"
}

,pulseaudio_list_2() {
	if (($# != 1)); then
		cat <<-EOF
	Usage:  ,pulseaudio_list_2 <fields> [jsonoutput]

	Fields is a comma separated list of lowercase fields.
	A special value "ALL" makes printing all possible fields.
	A special value "JSON" makes printing all possible fields in json format.
	Fields:
	  _what         Section name.
	  _num          Number of that thing.
	  _name         Smart name, from name or from application.name
	  _description  Smart description, description or module.description 
	                or device.description.
	All other fields that are outputted by pactl list.

	Examples:
	  ,pulseaudio_list_2 ALL
	  ,pulseaudio_list_2 JSON
	  ,pulseaudio_list_2 _what,_num,_name,_description,mute

	EOF
		return
	fi
	pactl list | awk \
		-v outputmode="$1" \
	'
		# props array stores all output globally with comma separated values

		function cur_clear( \
				i) {
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

		function jsonesc(input, \
				str) {
			str = input
			str = gensub(/([\\"])/, "\\\\\\1", "g", str) 
			return str
		}
		function remove_quotes(input, \
				str) {\
			str = input
			# Tab is the output separator - its not allowed.
			str = gensub(/\t/, "\\\\t", "g", str)
			# If there are quotes exactly in front and after it, remove them.
			if (str ~ "^\"[^\"]*\"$") {
				str = gensub(/"/, "", "g", str)
			}
			return str
		}


		BEGIN {
			OFS="\t"
		}

		# read the lines "something #<number>"
		/^[^ ]*.* #[0-9]*$/ {
			cur["_what"] = what = gensub(" *#.*", "", "1", $0);
			cur["_num"]  = num  = gensub(".*#",   "", "1", $0);
		}

		# all other lines start with a leading tab
		length(what) && /^\t[^\t]/ {
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
				val = remove_quotes(val)
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
			val = remove_quotes(val)
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
		
		function output( \
				c, i, val, once, scur) {
			if (outputmode == "JSON") {
				printf "{"
				once = 0
				for (i in cur) {
					printf "%s\"%s\": \"%s\"", once++?",":"", jsonesc(i), jsonesc(cur[i])
				}
				printf "}\n"
			} else if (outputmode == "ALL") {
				if (!_output_header) {
					_output_header = 1
					printf "%s\t%s\t%s\t%s\n", "what", "num", "field", "value"
				}
				asorti(cur, scur)
				i = length(scur)
				for (i = 1; i <= length(scur); ++i) {
					printf "%s\t%s\t%s\t%s\n", what, num, scur[i], cur[scur[i]]
				}
			} else if (outputmode) {
				if (!_output_header) {
					_output_header = 1
					print gensub(",", "\t", "g", outputmode)
				}
				split(outputmode, c, ",")
				for (i = 1; i <= length(c); ++i) {
					val = cur[c[i]]
					printf "%s%s", length(val) ? val : "-", i==length(c)?"":OFS
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
		return
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

