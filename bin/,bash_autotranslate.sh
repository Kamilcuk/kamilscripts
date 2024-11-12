#!/bin/bash
# vim: foldmethod=marker

# Sourced {{{1

# shellcheck disable=1135,2094,1090,1004

# Are we sourced?
if [[ "${BASH_SOURCE[0]}" != "${0}" || "${BASH_AUTOTRANSLATE_SOURCE:-}" = "true" ]]; then

	# We create a temporary directory for translations and set TEXTDOMAIN and TEXTDOMAINDIR.
	TEXTDOMAIN="${TEXTDOMAIN:-bash_autotranslate}" &&
	export TEXTDOMAIN &&
	TEXTDOMAINDIR=$(mktemp --tmpdir -d tmp.bash_autotranslate.XXXXXXXXXX) &&
	export TEXTDOMAINDIR &&
	{
		# In a background process remove the temporary directory once the parent exits.
		(
			trap 'rm -rf "$TEXTDOMAINDIR"' EXIT
			# Poll for parent pid to die!
			# This is the same that tail --pid= does anyway.
			while kill -s 0 "$$" 2>/dev/null >&2; do sleep 1; done
			# Then remove temporary directory in trap.
		) &
		# Generate translations. Uses TEXTDOMAINDIR and TEXTDOMAIN.
		if ! "${BASH_SOURCE[0]}" "$@" --translate "${BASH_SOURCE[1]}"; then exit 1; fi
	}

	return
fi

# Script start {{{1

set -euo pipefail
export SHELLOPTS

# Tests {{{1

run_tests() {
	set -euo pipefail

	tmp1=$(mktemp --tmpdir tmp.bash_autotranslate.XXXXXXXXXX)
	tmp2=$(mktemp --tmpdir tmp.bash_autotranslate.XXXXXXXXXX)
	tmp3=$(mktemp --tmpdir tmp.bash_autotranslate.XXXXXXXXXX)
	trap 'rm "$tmp1" "$tmp2" "$tmp3"' EXIT
	diff() {
		command diff -Naur "$@"
	}
	for i in ${1:-1 2 3 4 5 6}; do
		echo "###### running test $i" >&2
		(
			set -euo pipefail
			trap 'echo "##### test $i failed"' EXIT
			"tests_$i"
			trap '' EXIT
		)
		echo
	done
	echo "###### tests SUCCESS" >&2
}

tests_1() {
	cat <<EOF >"$tmp1"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"

exit

#### bash_autotranslate pl_PL
#### bash_autotranslate END

EOF
	cat <<EOF >"$tmp2"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"

exit

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

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr ""

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr ""

#### bash_autotranslate END

EOF
	"$0" "$tmp1" > "$tmp3"
	diff "$tmp3" "$tmp2"
}

tests_2() {
	cat <<EOF2 >"$tmp1"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"
echo $"New thing to translate!"

exit

: <<"EOF"
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

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr "To jest przykładowy skrypt do pokazania generacji translacji"

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr "Witaj świecie!"

#### bash_autotranslate END
EOF

EOF2
	cat <<EOF2 >"$tmp2"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"
echo $"New thing to translate!"

exit

: <<"EOF"
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

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr "To jest przykładowy skrypt do pokazania generacji translacji"

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr "Witaj świecie!"

#: $(basename "$tmp1"):8
msgid "New thing to translate!"
msgstr ""

#### bash_autotranslate END
EOF

EOF2
	"$0" "$tmp1" > "$tmp3"
	diff "$tmp2" "$tmp3"
	LC_MESSAGES=C bash "$tmp1" > "$tmp2"
	cat <<EOF >"$tmp3"
This is a sample script to show generating translate to work
Hello world
New thing to translate!
EOF
	diff "$tmp2" "$tmp3"
	LC_MESSAGES=pl_PL.UTF-8 bash "$tmp1" > "$tmp2"
	cat <<EOF >"$tmp3"
To jest przykładowy skrypt do pokazania generacji translacji
Witaj świecie!
New thing to translate!
EOF
	diff "$tmp2" "$tmp3"
}

tests_3() {
	cat <<EOF2 >"$tmp1"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"

exit

: <<"END"
#### bash_autotranslate pl_PL
#### bash_autotranslate de_DE
#### bash_autotranslate END
END


EOF2
	cat <<EOF2 >"$tmp2"
#!/bin/bash

# setup
. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"

exit

: <<"END"
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

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr ""

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr ""

#### bash_autotranslate de_DE
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Last-Translator: Automatically generated\n"
"Language-Team: none\n"
"Language: de\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr ""

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr ""

#### bash_autotranslate END
END


EOF2
	"$0" "$tmp1" > "$tmp3"
	diff "$tmp3" "$tmp2"
}

tests_4() {
	cat <<EOF >"$tmp1"
#!/bin/bash


. "$0"

echo $"This is a sample script to show generating translate to work"
echo $"Hello world"

exit

: <<"END"
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

# some initial comment
#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr "To jest przykładowy skrypt pokazujący jak działa translacja"

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr "Witaj świecie"

#### bash_autotranslate de_DE
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Last-Translator: Automatically generated\n"
"Language-Team: none\n"
"Language: de\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"

#: $(basename "$tmp1"):6
msgid "This is a sample script to show generating translate to work"
msgstr "Dies ist ein Beispielskript, das zeigt, wie das Übersetzen in die Arbeit generiert wird"

#: $(basename "$tmp1"):7
msgid "Hello world"
msgstr "Hallo Welt"

#### bash_autotranslate END
END


EOF
	echo "Stage 0"
	"$0" -O "$tmp1" > "$tmp2"
	diff "$tmp1" "$tmp2"
	"$0" -i "$tmp1"
	diff "$tmp1" "$tmp2"


	echo "Stage 1"
	LC_MESSAGES=C bash "$tmp1" > "$tmp2"
	cat <<EOF >"$tmp3"
This is a sample script to show generating translate to work
Hello world
EOF
	diff "$tmp2" "$tmp3"

	echo "Stage 2.1"
	cat <<EOF >"$tmp3"
To jest przykładowy skrypt pokazujący jak działa translacja
Witaj świecie
EOF
	LANGUAGE=pl_PL bash "$tmp1" > "$tmp2"
	diff "$tmp2" "$tmp3"

	echo "Stage 2.2"
	LANGUAGE=pl_PL.UTF-8 bash "$tmp1" > "$tmp2"
	diff "$tmp2" "$tmp3"

	echo "Stage 3.1"
	cat <<EOF >"$tmp3"
Dies ist ein Beispielskript, das zeigt, wie das Übersetzen in die Arbeit generiert wird
Hallo Welt
EOF
	LANGUAGE=de_DE bash "$tmp1" > "$tmp2"
	diff "$tmp2" "$tmp3"

	echo "Stage 3.2"
	LANGUAGE=de_DE.UTF-8 bash "$tmp1" > "$tmp2"
	diff "$tmp2" "$tmp3"
}

tests_will_fail() {
	local tmp
	if tmp=$("$0" "$1" 2>&1) || [[ -z "$tmp" ]]; then
		{
			printf "Parsing the following should have failed, but didn't\n"
			echo ---------------------------------
			cat "$1"
			echo ---------------------------------
			echo "tmp=$tmp"
			echo ---------------------------------
		} >&2
		return 1
	fi
}
tests_5() {
	log "Stage 1"
	cat <<EOF >"$tmp1"
#### bash_autotranslate pl_PL
#### bash_autotranslate END
#### bash_autotranslate END
EOF
	tests_will_fail "$tmp1"

	log "Stage 2"
	cat <<EOF >"$tmp1"
#### bash_autotranslate pl_PL
####  bash_autotranslate 	ulubankga
####  bash_autotranslate 	en_US
####        bash_autotranslate        pl_PL
####   bash_autotranslate   END
EOF
	tests_will_fail "$tmp1"

	log "Stage 3"
	cat <<EOF >"$tmp1"
#### bash_autotranslate pl_PL
####  bash_autotranslate 	ulubankga
####  bash_autotranslate 	en_US
EOF
	tests_will_fail "$tmp1"

	log "Stage 4"
	cat <<EOF >"$tmp1"
####  bash_autotranslate 	pl_PL
####  bash_autotranslate 	en_US
####  bash_autotranslate 	ulubankga
####  bash_autotranslate 	 END
EOF
	"$0" -q "$tmp1" >/dev/null

	log "Stage 5"
	cat <<EOF >"$tmp1"
#### bash_autotranslate pl_PL
msgid "missing invalid"
#### bash_autotranslate en_US
#### bash_autotranslate END
EOF
	tests_will_fail "$tmp1"
}

tests_6() {
	cat <<EOF >"$tmp1"
echo $"one message"
echo $"another message"
echo $"one message"
echo $"yet another message"
echo $"one message"

#### bash_autotranslate pl_PL
#### bash_autotranslate en_US
#### bash_autotranslate END
EOF
	"$0" -q "$tmp1" >/dev/null
}

# Awk parser {{{1

bash_autotranslate_parser() {
	# These environment variables are used to pass stuff to awk inside.
	# It's the best method and you are expected to set them outside.
	# See BEGIN{} section below to how are they consumed
		g_regex="${g_regex:-}" \
		mode="${mode:-}" \
		regenerate_section="${regenerate_section:-}" \
	awk -v loglevel="$loglevel" '

function cerr(msg) {
	print msg > "/dev/stderr"
}

function error(msg) {
	printf("bash_autotranslate: ERROR: parsing %s:%d: %s\n", FILENAME, FNR, msg) > "/dev/stderr"
	_error_exit = 1
	exit 1
}

function arrprint(name, arr, \
		i) {
	for (i in arr) {
		cerr(name"["i"] = "arr[i])
	}
}

# The hearth of this code.
# Actually parse the segment and sections.
function parse() {
	# Detect mark
	if ($0 ~ g_regex) {
		marks[markscnt++] = $0
		label = $3
		if (label != "END") {
			if (segm_end != 0) {
				error("two autotranslate separate segments detected")
			}
			segm_inside = 1
			segm_start = NR
			for (i in languages) {
				if (languages[i] == label) {
					error("language section "label" specified twice")
				}
			}
			languages[languagescnt++] = label
			section[sectioncnt++] = ""
		} else {
			# label == END
			if (segm_stop != 0) {
				error("two autotranslate endings detected")
			}
			segm_stop = NR
			# segm_inside = 0 # see below
		}
		return
	}

	if (segm_stop) {
		# delay one line, so it can be detected properly
		segm_inside = 0
	}

	if (segm_inside == 0) {
		return
	}

	if (sectioncnt == 0) {
		error("Internal error: Reading lines into section but section not detected")
	}
	# Add the line to the section.
	section[sectioncnt - 1] = section[sectioncnt - 1] $0 "\n"
}

function parse_check() {
	if (segm_start == 0) {
		error("segment not detected")
	}
	if (segm_start != 0 && segm_stop == 0) {
		error("missing segment closing mark segm_start="segm_start)
	}
	if (languagescnt == 0) {
		error("empty segment found - no languages to convert")
	}
	if (sectioncnt != languagescnt) {
		error("internal error: sectioncnt="sectioncnt" != languagescnt="languagescnt)
	}
	if (markscnt != sectioncnt + 1) {
		error("internal error: markscnt="markscnt" != sectioncnt="sectioncnt" + 1")
	}
}

# Extract the data in a format consumed later in bash.
function extract() {
	# First chunk has languages on lines
	for (i = 0; i < languagescnt; ++i) {
		printf "%s\n", languages[i]
	}
	printf "\x01"
	for (i = 0; i < markscnt; ++i) {
		printf "%s\n", marks[i]
	}
	for (i = 0; i < sectioncnt; ++i) {
		# separated by 0x01 bytes, come sections
		printf "\x01"
		printf "%s", section[i]
	}
}

# Create a new file from the input file replacing the segment with the content of environment variable.
function regenerate() {
	if (!segm_inside) {
		print
	} else {
		if (!regenerate_once) {
			regenerate_once=1
			if (length(ENVIRON["regenerate_section"]) == 0) {
				error("regenerate called but empty section")
			}
			print ENVIRON["regenerate_section"]
		}
	}
}

###############################################################################

BEGIN {
	g_mode = ENVIRON["mode"] # current execution mode
	if (g_mode != "regenerate" && g_mode != "extract") {
		error("internal error: invalid mode=" g_mode);
	}

	g_regex = ENVIRON["g_regex"]
	if (length(g_regex) == 0) {
		g_regex = "^####[[:space:]]+bash_autotranslate[[:space:]]+[^ ]+[[:space:]]*$"
	}
	if (loglevel >= 2) {
		cerr("Using regex=" g_regex)
	}

	segm_start = 0   # Where out segment starts.
	segm_stop = 0    # The ending line of our segment.
	segm_inside = 0  # If we are inside the segmend.

	presection = "" # the stuff between beginning mark, but before any langauge section.
	# languages # The array with languages
	languagescnt = 0 # Count of the above array
	# section # The content of the section for specific language.
	sectioncnt = 0 # The count of sections, repsectively
}

{
	parse()
	if (g_mode == "regenerate") { regenerate(); }
}

END {
	if (_error_exit) exit(1)
	parse_check();
	if (g_mode == "extract") { extract(); }
}

	' "$@"
}

awk_po_strings_deduplicate() {
	# It seems that bash --dump-po-strings doesn't handle duplicate messages.
	# It seems that msgfmt doesnt like duplicate messages.
	# so aggregate duplicates together.
	awk '
function cerr(msg) {
	print msg > "/dev/stderr"
}

function error(msg) {
	printf("bash_autotranslate: ERROR: internal error: bash --dump-po-strings:%d: %s: \n", FNR, msg, $0) > "/dev/stderr"
	_error_exit = 1
	exit 1
}

# Like getline, but error.
function Getline() {
	if (getline <= 0) {
		error("unexpected EOF or error: " ERRNO);
	}
}

{
	if ($0 !~ /^#: /) {
		error("missing line starting with #:")
	}
	comment = $0

	Getline()
	if (gsub(/^msgid "/, "", $0) != 1 || gsub(/"$/, "", $0) != 1) {
		error("missing line starting with msgid")
	}
	msgid = $0

	Getline()
	if (gsub(/^msgstr ""$/, "", $0) != 1) {
		error("missing msgstr line with empty \"\"")
	}

	if (!(msgid in comments)) {
		msgids[msgidscnt++] = msgid
	}
	comments[msgid] = comments[msgid] comment "\n"
}

END {
	if (_error_exit) exit(1)
	for (i = 0; i < msgidscnt; ++i) {
		printf "%smsgid \"%s\"\nmsgstr \"\"\n\n", comments[msgids[i]], msgids[i]
	}
}
	'
}

# Functions {{{1

log() {
	if ((loglevel)); then
		printf "%s\n" "$*" >&2
	fi
}

logstream() {
	if ((loglevel)); then
		cat
	else
		cat >/dev/null
	fi
}

logrun() {
	if ((loglevel >= 2)); then
		log "+" "$@"
	fi
	"$@" 2>&1 | logstream >&2
}

error() {
	echo "bash_autotranslate: ERROR:" "$@" >&2
	exit 1
}

output_template() {
	cat <<SUPEREOF
: <<EOF
#### bash_autotranslate en_US.UTF-8
#### bash_autotranslate pl_PL.UTF-8
#### bash_autotranslate END
EOF
SUPEREOF
}

help() {
	tmp=$(mktemp)
	trap 'rm "$tmp"' EXIT
	pod2man --section=1 --center="General Commands Manual" --release="1.0" <<"SUPER_EOF" >"$tmp"
=encoding UTF-8

=head1 NAME

,bash_autotranslate.sh - automatically generate translations for bash scripts on the fly

=head1 USAGE

See C<,bash_autotranslate.sh -h> for command line options.

To regenerate script translations use:

    ,bash_autotranslate.sh ./path/to/script

When you are happy with the changes, you may use B<-i> command line option to modify the script in-place.

From within the to-be-translated script source the autotranslate script:

    source ,bash_autotranslate.sh

You may use B<--regex> command line option to specify the regex, also when sourcing.

=head1 STARTUP

To start working with the script:

=over 4

=item - Write some starting script

=item - Source this script in your script somewhere at the beginning, like:

    . ,bash_autotranslate.sh

=item - Add the templating part, so something along:

    blabla your script
    exit # no point in running past here

    : <<'EOF'  # you may want to use here document to disable ex. IDE highlighting
    #### bash_autotranslate pl_PL.UTF-8
    #### bash_autotranslate de_DE.UTF-8
    #### bash_autotranslate pt_PT.UTF-8
    #### bash_autotranslate <another language here>
    #### bash_autotranslate END
    EOF

=over 8

=item - See also the output of C<,bash_autotranslate.sh --template>

=back

=item - Then execute C<,bash_autotranslate.sh your_script.sh>

=over 8

=item - The script will run msginit and insert a new script with the C<: <<bash_autotranslate> part substituted
   with msginit outputs.

=item - View the generate C<tempfile>. If you are happy with the changes, copy the tempfile as your new script.

=back

=item - Then you can add translations.

=item - Now

=item - If you add new messages C<echo $"new message">

=item - Then re-run C<,bash_autotranslate.sh your_script.sh> and inspect the output and regenerate the file.

=over 8

=item - It will run msgmerge over the translations trying to merge them

=item - If you are happy with the changes, re-run with B<-i> or B<--in-place> option.

=item - Current translations will not be lost - msgmerge should handle that.

=back

=item - Add your translation.

=item - When you add new message, repeat the process, regenerate, and go.

=back

=head1 EXAMPLE1

First the following script is created and saved as C<script.sh>:

    #!/bin/bash
    . ,bash_autotranslate.sh
    echo $"Some message"
    exit
    : <<EOF
    #### bash_autotranslate pl_PL.UTF-8
    #### bash_autotranslate de_DE.UTF-8
    #### bash_autotranslate END
    EOF

Then execute from command line:

    ,bash_autotranslate.sh -i ./script.sh


This will modify C<./script.sh> and result in:

    #!/bin/bash
    . ,bash_autotranslate.sh
    echo $"Some message"
    exit
    : <<EOF
    #### bash_autotranslate pl_PL.UTF-8
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

    #: script.sh:3
    msgid "Some message"
    msgstr ""

    #### bash_autotranslate de_DE.UTF-8
    msgid ""
    msgstr ""
    "Project-Id-Version: PACKAGE VERSION\n"
    "Last-Translator: Automatically generated\n"
    "Language-Team: none\n"
    "Language: de\n"
    "MIME-Version: 1.0\n"
    "Content-Type: text/plain; charset=UTF-8\n"
    "Content-Transfer-Encoding: 8bit\n"
    "Plural-Forms: nplurals=2; plural=(n != 1);\n"

    #: script.sh:3
    msgid "Some message"
    msgstr ""

    #### bash_autotranslate END
    EOF

Now you may insert the translation in specific C<msgstr> places, like:

    #!/bin/bash
    . ,bash_autotranslate.sh
    echo $"Some message"
    exit
    : <<EOF
    #### bash_autotranslate pl_PL.UTF-8
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

    #: script.sh:3
    msgid "Some message"
    msgstr "Jakaś wiadomość"

    #### bash_autotranslate de_DE.UTF-8
    msgid ""
    msgstr ""
    "Project-Id-Version: PACKAGE VERSION\n"
    "Last-Translator: Automatically generated\n"
    "Language-Team: none\n"
    "Language: de\n"
    "MIME-Version: 1.0\n"
    "Content-Type: text/plain; charset=UTF-8\n"
    "Content-Transfer-Encoding: 8bit\n"
    "Plural-Forms: nplurals=2; plural=(n != 1);\n"

    #: script.sh:3
    msgid "Some message"
    msgstr "Eine Nachricht"

    #### bash_autotranslate END
    EOF

After the edit, when executing the script it will be translated:

    $ LC_ALL=C ./script.sh
    Some message
    $ LC_MESSAGES=pl_PL.UTF-8 ./script.sh
    Jakaś wiadomość
    $ LANGUAGE=de_DE.UTF-8 ./script.sh
    Eine Nachricht

=head1 EXAMPLE2

Yet another example. The follwing script:

    #!/bin/bash

    . ,bash_autotranslate.sh

    echo $"Insert first number"
    read num

    echo $"Insert second number"
    read num2

    num3=$((num + num2))
    printf $"The result is equal to: %d\n" "$num3"

    exit

    : <<'EOF' # here document is just to disable IDE syntax checking
    # The translation starts here
    # Comments are actually ignored, as msgfmt ignores them anyway too.
    # The following is a translation for en_US:
    #### bash_autotranslate en_US
    #                       ^^^^^     - this is the langauge
    # ^^^^^^^^^^^^^^^^^^^^^           - this is constant string
    # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv - the following is generated from msginit
    msgid ""
    msgstr ""
    "Project-Id-Version: PACKAGE VERSION\n"
    "Last-Translator: Automatically generated\n"
    "Language-Team: none\n"
    "Language: en_US\n"
    "MIME-Version: 1.0\n"
    "Content-Type: text/plain; charset=UTF-8\n"
    "Content-Transfer-Encoding: 8bit\n"
    "Plural-Forms: nplurals=2; plural=(n != 1);\n"

    #: longer_script.sh:5
    msgid "Insert first number"
    msgstr "Insert first number"

    #: longer_script.sh:8
    msgid "Insert second number"
    msgstr "Insert first number"

    #: longer_script.sh:12
    msgid "The result is equal to: %d\\n"
    msgstr ""

    # ------------------------------- and here starts the translation for polish language:
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

    #: longer_script.sh:5
    msgid "Insert first number"
    msgstr "Wprowadź pierwszą liczbę"

    #: longer_script.sh:8
    msgid "Insert second number"
    msgstr "Wprowadź drugą liczbę"

    #: longer_script.sh:12
    msgid "The result is equal to: %d\\n"
    msgstr "Wynik jest równy: %d\\n"

    #### bash_autotranslate END
    #                       ^^^ - translation ends
	EOF

The script when executed would output:

    $ ./the_script.sh
    Insert first number
    1
    Insert first number
    2
    The result is equal to: 3

However executing with polish language:

    $ export LC_MESSAGES=pl_PL
    $ ./the_script.sh
    Wprowadź pierwszą liczbę
    1
    Wprowadź drugą liczbę
    2
    Wynik jest równy: 3

it will provide polish translation.

=head1 AUTHOR

Written by Kamil Cukrowski <kamilcukrowski@gmail.com>

=head1 REPORTING BUGS

Just write me or post it on my gitlab.com page.

=head1 COPYRIGHT

Licensed under GPL-3.0.

=head1 SEE ALSO

L<msginit(1)> L<msgmerge(1)> L<bash(1)> L<gettext(1)>

SUPER_EOF
	set +euo pipefail
	man -l "$tmp"
}

usage() {
	cat <<EOF
Usage: "$(basename "$0")" [options] <file>

Automatically generate translation from bash script sources with gettext.
The script is meant to be sourced from bash script, in which case it sets
and exports TEXTDOMAIN and TEXTDOMAINDIR variables and generates translations
from the script using special tags. In case the file is run from command line
and not sourced, it output file content with updated po-strings information
as extracted from running bash --dump-po-strings on the script.

Options:
  -q                Be quiet!
  -v --verbose      Be verbose!
     --template     Print sample a template section to add to script.
  -O --output       Output the script to stdout, even when there are no changes.
  -i --in-place[=SUF]    Edit the file in-place. Optional suffix used to create backup.
     --translate    Generate translations for TEXTDOMAIN in TEXTDOMAINDIR.
     --regex=REGEX  Use this regex in awk when matching markings.
  -h                Print this help and exit.
     --help         View longer help as a man page and exit. Depends on pod2man.
     --test[=N]     Run tests.

Written by Kamil Cukrowski
SPDX-License-Identifier: GPL-3.0
EOF
}

# main {{{1

args=$(getopt -n ",bash_autotranslate" -o qhOi::v -l help,translate,template,test::,output,in-place::,verbose,regex: -- "$@")
eval set -- "$args"
loglevel=1
mode=generate
in_place=false
in_place_suffix=""
g_regex=""
g_output=false
while (($#)); do
	case "$1" in
	-q) loglevel=0; ;;
	-h) usage; exit; ;;
	--help) help; exit; ;;
	--translate) mode=translate; ;;
	--template) output_template; exit; ;;
	--test) run_tests "${2:-}"; shift; exit; ;;
	-O|--output) g_output=true; ;;
	-i|--in-place) in_place=true; in_place_suffix="${2:-}"; shift; ;;
	-v|--verbose) loglevel=$((loglevel+1)); ;;
	--regex) g_regex="$2"; shift; ;;
	--) shift; break; ;;
	*) error "internal error on parsing arguments: $*" ;;
	esac
	shift
done

if [[ "$mode" != "translate" ]]; then
	# Yes, we are sourcing ourselves, to load translation to ourselves.
	# This is not done in translate mode, cause this mode is executed when sourcing.
	# So to pretect against recursive endless loop.
	BASH_AUTOTRANSLATE_SOURCE=true
	. "$0" --regex="^#:#:#:#: bash_autotranslate [^ ]*$"
fi

if (($# == 0)); then usage; error "missing argument"; fi
if (($# != 1)); then error "invalid arguments: $*"; fi
inputfile="$1"
readonly inputfile

# Parser prints it's own error message.
tmp=$(mode=extract bash_autotranslate_parser "$inputfile")
section=(); IFS=$'\x01' read -d '' -r -a section <<<"$tmp" ||:
if ((${#section} == 0)); then fatal "internal error: failed reading section from parser"; fi
readarray -t languages < <(printf "%s" "${section[0]}")
readarray -t marks < <(printf "%s" "${section[1]}")
unset 'section[0]' 'section[1]'
section=("${section[@]}")
sectioncnt=${#languages[@]}
if ((${#marks[@]} != ${#section[@]} + 1)); then
	error "parser error: marks invalid count: ${#marks[@]} != ${#section[@]}"
fi
if ((${#languages[@]} != ${#section[@]})); then
	error "parser error: number of languages is not equal to number of sections: ${#marks[@]} != ${#languages[@]} != ${#section[@]}"
fi
if ((!sectioncnt)); then error "no languages detected"; fi
readonly section languages sectioncnt marks
readonly TEXTDOMAIN TEXTDOMAINDIR

case "$mode" in
translate)
	if [[ ! -d "$TEXTDOMAINDIR" ]]; then error "TEXTDOMAINDIR: no such directory: $TEXTDOMAINDIR"; fi
	if [[ -z "$TEXTDOMAIN" ]]; then error "TEXTDOMAIN is empty"; fi
	for ((i = 0; i < ${#languages[@]}; ++i)); do
		dir="$TEXTDOMAINDIR/${languages[i]}/LC_MESSAGES/"
		mkdir -p "$dir"
		msgfmt -o "$dir/$TEXTDOMAIN.mo" - <<<"${section[i]}"
	done
	;;

generate)
	if (($# != 1)); then error "invalid count of arguments"; fi

	tmp_pos=$(mktemp --tmpdir tmp.bash_autotranslate.XXXXXXXXXX.pos)
	trap 'rm -f "$tmp_pos"' EXIT
	tmp_po=$(mktemp --tmpdir tmp.bash_autotranslate.XXXXXXXXXX.po)
	trap 'rm -f "$tmp_pos" "$tmp_po"' EXIT

	log $"Getting po-strings from the file""..."
	( cd "$(dirname "$inputfile")" && bash --dump-po-strings "$(basename "$inputfile")" ) |
		awk_po_strings_deduplicate > "$tmp_pos"

	for ((i = 0; i < sectioncnt; ++i)); do
		out+="${marks[i]}"$'\n'
		cat <<<"${section[i]}" >"$tmp_po"

		lang=${languages[i]}
		add_utf=false
		if [[ ! "$lang" =~ \. ]]; then
			# When encoding is missing, default to UTF-8, not to "ASCII", as msginit does.
			lang+=".UTF-8"
			add_utf=true
		fi

		if [[ "${section[i]}" =~ ^$'\n'*$ ]]; then

			log $"Initializing translation to"" ${languages[i]}..."
			cmd=(msginit --no-wrap --no-translator -l "$lang" -i "$tmp_pos" -o "$tmp_po")
		else
			log $"Updating translation to"" ${languages[i]}..."
			cmd=(msgmerge --no-wrap --quiet --backup=none --update "$tmp_po" "$tmp_pos")
		fi
		if ! logrun "${cmd[@]}"; then
			if ((loglevel >= 2)); then
				sed 's/^/*.pos: /' "$tmp_pos" | cat -n >&2
			fi
			exit 1
		fi
		if "$add_utf" && [[ "${cmd[0]}" == "msginit" ]]; then
			# Yes, I _REALLY_ want UTF-8
			sed -i -e 's@^"Content-Type: text/plain; charset=ASCII\\n"$@"Content-Type: text/plain; charset=UTF-8\\n"@' "$tmp_po"
		fi

		# Remove leading empty lines with sed.
		# It seems that msgmerge inserts empty leading lines or maybe it's my awk, dunno.
		out+=$(sed '/./,$!d' "$tmp_po")$'\n\n'
	done
	out+="${marks[sectioncnt]}"

	# Reusing tmp_po temporary file here
	mode="regenerate" regenerate_section="$out" bash_autotranslate_parser "$inputfile" > "$tmp_po"
	if cmp -s "$tmp_po" "$inputfile"; then
		log $"File is up to date""."
	else
		if ! "$in_place"; then
			log $"Replace file content with the following content"":"
			g_output=true # Used below
		else
			if [[ -n "$in_place_suffix" ]]; then
				log $"Creating backupfile"" $inputfile$in_place_suffix"
				cp -n "$inputfile" "$inputfile""$in_place_suffix"
			fi
			log $"Replacing file content in place"
			cp "$tmp_po" "$inputfile"
		fi
	fi
	if "$g_output"; then
		log ""
		cat "$tmp_po"
	fi
	;;
esac

exit

# Translation {{{1

# Use ,bash_autotranslate.sh --regex="^#:#:#:#: bash_autotranslate [^ ]*$" ,bash_autotranslate.sh
: <<EOF
#:#:#:#: bash_autotranslate pl_PL
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

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1003
msgid "Getting po-strings from the file"
msgstr "Pobieranie po-strings z pliku"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1016
msgid "Initializing translation to"
msgstr "Inicjalizacja tłumaczenia do"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1019
msgid "Updating translation to"
msgstr "Odświerzenie tłumaczenia do"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1038
msgid "File is up to date"
msgstr "Plik jest aktualny"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1041
msgid "Replace file content with the following content"
msgstr "Podmień zawartość plik na następującą zawartość"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1046
msgid "Creating backupfile"
msgstr "Tworzenie pliku zapasowego"

#: /usr/lib/kamilscripts/bin/,bash_autotranslate.sh:1049
msgid "Replacing file content in place"
msgstr "Podmiana zawortości pliku w miejscu"

#:#:#:#: bash_autotranslate END
EOF


