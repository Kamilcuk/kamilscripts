## Index

* [L_argparse_error](#largparseerror)
* [L_argparse_print_help](#largparseprinthelp)
* [L_argparse_print_usage](#largparseprintusage)
* [_L_argparse_split](#largparsesplit)
* [L_argparse_init](#largparseinit)
* [L_argparse_add_argument](#largparseaddargument)
* [_L_argparse_kvcopy](#largparsekvcopy)
* [_L_argparse_parser_next_settings](#largparseparsernextsettings)
* [_L_argparse_parser_find_settings](#largparseparserfindsettings)
* [_L_argparse_settings_is_argument](#largparsesettingsisargument)
* [_L_argparse_settings_validate_value](#largparsesettingsvalidatevalue)
* [_L_argparse_settings_assign_array](#largparsesettingsassignarray)
* [_L_argparse_settings_execute_action](#largparsesettingsexecuteaction)
* [L_argparse_parse_args](#largparseparseargs)

### L_argparse_error

Print argument parsing error.

#### Environment variables

* L_NAME
* _L_mainsettings

#### Exit codes

* **2**: if exit_on_error

### L_argparse_print_help

Print help or only usage for given parser or global parser.

#### Options

* **-s --short**

  print only usage, not full help

#### Arguments

* **$1** (_L_parser): or

#### Environment variables

* _L_parser

### L_argparse_print_usage

Print usage.

### _L_argparse_split

Split '-o --option k=v' options into an associative array.

#### Options

* * arguments to parse

#### Arguments

* $1 argparser
* **$2** (index): into argparser. Index 0 is the ArgumentParser class definitions, rest are arguments.
* $3 --

#### Variables set

* argparser[index]

### L_argparse_init

Initialize a argparser
Available parameters:
- prog - The name of the program (default: ${0##*/})
- usage - The string describing the program usage (default: generated from arguments added to parser)
- description - Text to display before the argument help (by default, no text)
- epilog - Text to display after the argument help (by default, no text)
- add_help - Add a -h/--help option to the parser (default: True)
- allow_abbrev - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: True)
- Adest - Store all values as keys into this associated dictionary

#### Options

* * Parameters

#### Arguments

* **$1** (The): parser variable
* **$2** (Must): be set to '--'

### L_argparse_add_argument

Add an argument to parser
Available parameters:
- name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
- action - The basic type of action to be taken when this argument is encountered at the command line.
- nargs - The number of command-line arguments that should be consumed.
- const - A constant value required by some action and nargs selections.
- default - The value produced if the argument is absent from the command line and if it is absent from the namespace object.
- type - The type to which the command-line argument should be converted.
  - Available types: float int positive nonnegative
- choices - A sequence of the allowable values for the argument.
- required - Whether or not the command-line option may be omitted (optionals only).
- help - A brief description of what the argument does.
- metavar - A name for the argument in usage messages.
- dest - The name of the attribute to be added to the object returned by parse_args().
- deprecated - Whether or not use of the argument is deprecated.
- validator - A script that validates the 'arg' argument.
  - For example: `validator='[[ $arg =~ ^[0-9]+$ ]]'`
- completion - A Bash script that generates completion.

#### Options

* * parameters

#### Arguments

* $1 parser
* $2 --

### _L_argparse_kvcopy

Copy associative dictionary

#### Arguments

* **$1** (The): name of one dictionary variable
* **$2** (The): name of the other dictionary variable

### _L_argparse_parser_next_settings

Iterate over all option settings.

#### Arguments

* **$1** (index): nameref, should be initialized at 1
* **$2** (settings): nameref

#### Environment variables

* _L_parser

### _L_argparse_parser_find_settings

Find option settings.

#### Arguments

* **$1** (What): to search for: -o --option
* **$2** (option): settings nameref

#### Environment variables

* _L_mainsettings
* _L_parser

### _L_argparse_settings_is_argument

#### Environment variables

* _L_settings

### _L_argparse_settings_validate_value

#### Arguments

* **$1** (value): to assign to option

#### Environment variables

* _L_settings

### _L_argparse_settings_assign_array

#### Environment variables

* _L_settings

### _L_argparse_settings_execute_action

#### Environment variables

* _L_settings
* _L_value
* _L_used_value

### L_argparse_parse_args

Parse the arguments with the given parser.

#### Options

* * arguments

#### Arguments

* **$1** (argparser): nameref
* $2 --

