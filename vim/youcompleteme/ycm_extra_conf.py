#!/usr/bin/env python3
import os
from os import getcwd
from os.path import abspath, join, isabs, normpath, exists, splitext, \
        dirname, realpath

ycmconf_compile_command_search_dirs = []
if os.path.isdir("_build"):
    ycmconf_compile_command_search_dirs += ["_build"]
    ycmconf_compile_command_search_dirs += [ f.path for d in ["_build"] for f in os.scandir(d) if f.is_dir() ]

# Configuration ###########################################################

# The loglevel of this script
ycmconf_loglevel = 0

# The search dirs for compile_commands.json file
# ycmconf_compile_command_search_dirs = ['.']

# Default flags in case compile_commands.json is not found.
ycmconf_default_flags = [
    "-Wall",
    "-Wextra",
    "-Wno-unknown-attributes",
    # "-Wno-unknown-pragmas",
]

# Compiler flags added if compiler cannot be detected.
ycmconf_default_compiler_flags = []

# Extra flags added always
ycmconf_extra_flags = []

# Flags added to a C-ish file
ycmconf_c_additional_flags = [ "-x","c","-std=gnu11", ]

# Flags added to a C++-ish file
ycmconf_cpp_additional_flags = [ "-x","c++","-std=gnu++17", ]

def defaults_set(clientdata):
    vars = [
            'ycmconf_loglevel',
            'ycmconf_default_flags',
            'ycmconf_default_compiler_flags',
            'ycmconf_extra_flags',
            'ycmconf_c_additional_flags',
            'ycmconf_cpp_additional_flags'
    ]
    for name in vars:
        for pre in ["g:", "b:"]:
            idx = pre + name
            if idx in clientdata:
                log("defaults_set: " + idx + " = " + repr(clientdata[idx]))
                exec('global %s\n%s = clientdata[idx]\n' % (name, name))

#############################################################################

c_source_extensions = [ ".c", ]
c_header_extensions = [ ".h", ]

cpp_source_extensions = [
    ".cp",
    ".cpp",
    ".CPP",
    ".cc",
    ".C",
    ".cxx",
    ".c++",
]
cpp_header_extensions = [
    ".hh",
    ".H",
    ".hp",
    ".hpp",
    ".HPP",
    ".hxx",
    ".h++",
]

########################################################################################

def logl(level, what):
    if level < ycmconf_loglevel:
        open("/tmp/ycmd_dupa", "a").write("AAAAA " + repr(what) + "\n")

def log(what):
    logl(1, what)

def is_exe(fpath):
    return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

def which(program):
    # https://stackoverflow.com/questions/377017/test-if-executable-exists-in-python
    import os
    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file
    return None

def find_file_recursively(file_name, start_dir = getcwd(), stop_dir = None):
    cur_dir = abspath(start_dir) if not isabs(start_dir) else start_dir
    while True:
        if exists(join(cur_dir, file_name)):
            return join(cur_dir, file_name)
        parent_dir = dirname(cur_dir)
        if parent_dir == cur_dir or parent_dir == stop_dir:
            return None
        else:
            cur_dir = parent_dir

def find_file_in_subdirs(filename, roots):
    for root in roots:
        if os.path.isdir(root):
            for root, dirs, files in os.walk(root):
                for dir in dirs:
                    f = os.path.join(root, filename)
                    if os.path.exists(f):
                        return f
    return None

def find_file_in_dirs(filename, dirs):
    for dir in dirs:
        if os.path.isdir(dir):
            f = os.path.join(dir, filename)
            if os.path.exists(f):
                return f
    return None

def getwhile(func, *a, **k):
    # https://stackoverflow.com/questions/2603956/can-we-have-assignment-in-a-condition
    while True:
        x = func(*a, **k)
        if not x:
            break
        yield x

def make_path_absolute(path, base_dir = getcwd()):
    if isabs(path):
        return path
    else:
        return join(base_dir, path)

def script_directory():
    return dirname(__file__)

def check_output(command):
    # https://stackoverflow.com/questions/5020538/python-get-output-from-a-command-line-which-exits-with-nonzero-exit-code
    process = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
    output = process.communicate()
    retcode = process.poll()
    if retcode:
            raise subprocess.CalledProcessError(retcode, command, output=output[0])
    return output

def get_compiler_flags(compiler, flags):
    import re, subprocess

    # extract only meaningfull flags - starting with -f and -m
    flags = [f for f in flags if f.startswith("-f") or f.startswith("-m")]

    # Run verbose compiler with no input and get compiler flags.
    tmp = subprocess.run( [compiler] + flags + ["-dM", "-E", "-v", "-x", "c", "/dev/null"], capture_output = True)
    if tmp.returncode != 0:
        return None
    stdout = tmp.stdout.decode('ascii').splitlines()
    stderr = tmp.stderr.decode('ascii')

    ret = []

    from os.path import realpath

    # Extract multilib and sysroot
    a, b = re.subn(r"^.* +-isysroot +([^ ]+).*$", r"\1", stderr, flags = re.MULTILINE + re.DOTALL)
    if b != 0 and os.path.exists(a):
        a = realpath(a)
        ret += [
                #"-nostdlib",
                "-nostdlibinc", # sorry - sysroot doesn't work with __include_next :/
                #"-nostdlib++",
                "--no-standard-includes",
                #"--sysroot=" + a,
                "-isysroot", a,
                #"--sysroot", a,
                "-I" + a + "/include",
        ]

    # extract include paths
    a, b = re.subn(r".*\n#include <\.\.\.> search starts here:[^\n]*\n(.*)End of search list\..*", r"\1", stderr, flags = re.MULTILINE + re.DOTALL)
    if b != 0:
        a, b = re.subn(r"[ ]*", r"", a)
        if b != 0:
            a = a.splitlines()
            for i in a:
                if os.path.exists(i):
                    i = realpath(i)
                    ret += [ "-I" + i ]

    # Doesn't work anyway
    # a, b = re.subn(r"^.* +-imultilib +([^ ]+).*$", r"\1", stderr, flags = re.MULTILINE + re.DOTALL)
    # if b != 0:
    #    ret += ["-imultilib", a]

    for i in stdout:
        # get all macros, but ignore function macros
        a, b = re.subn(r"^ *# *define +([^ \(\)]+) +(.+)$", r"-D\1=\2", i)
        if b != 0:
            ret += [a]
        continue
        # get all macros, for reference
        # a, b = re.subn(r"^ *# *define +([^ ]+) +(.+)$", r"-D\1=\2", i)
        #if b != 0:
        #    ret += [a]

    return ret

def is_c_or_cpp_header(file_path):
    return is_c_header(file_path) or is_cpp_header(file_path)

def is_c_header(file_path):
    (_, extension) = splitext(file_path)
    return extension in c_header_extensions

def is_cpp_header(file_path):
    (_, extension) = splitext(file_path)
    return extension in cpp_header_extensions

def is_c_or_cpp_source(file_path):
    return is_c_source(file_path) or is_cpp_source(file_path)

def is_c_source(file_path):
    (_, extension) = splitext(file_path)
    return extension in c_source_extensions

def is_cpp_source(file_path):
    (_, extension) = splitext(file_path)
    return extension in cpp_source_extensions

def is_c_file(file_path):
    return is_c_source(file_path) or is_c_header(file_path)

def is_cpp_file(file_path):
    return is_cpp_source(file_path) or is_cpp_header(file_path)

def make_absolute_flags(flags, base_dir):
    """
    Makes all paths in the given flags which are relative absolute using
    the given base directory.

    :param flags: The list of flags which should be made absolute.
    :type flags: list[str]
    :param base_dir: The directory which should be used to make the relative
                     paths in the flags absolute.
    :type base_dir: str
    :rtype: list[str]
    :return: The list of flags with just absolute file paths.
    """
    # The list of flags which require a path as next flag.
    next_is_path = [
        "-I",
        "-isystem",
        "-iquote"
    ]

    # The list of flags which require a path as argument.
    argument_is_path = [
        "--sysroot="
    ]

    updated_flags = []
    make_absolute = False

    for flag in flags:
        updated_flag = flag

        if make_absolute:
            # Assume that the flag is a path.
            updated_flag = make_path_absolute(flag, base_dir)

            make_absolute = False

        # Check for flags which expect a path as next flag.
        if flag in next_is_path:
            # The flag following this one must be a path which may needs
            # to be made absolute.
            make_absolute = True

        # Check the flags which normally expect as the next flag a path,
        # but which are written in one string.
        for f in next_is_path:
            if flag.startswith(f):
                path = flag[len(f):].lstrip()

                # Split the flag up in two separate ones. One with the actual
                # flag and one with the path.
                updated_flags.append(f)
                updated_flag = make_path_absolute(path, base_dir)

                break

        # Check for flags which expect a path as argument.
        for f in argument_is_path:
            if flag.startswith(f):
                path = flag[len(f):].lstrip()
                updated_flag = f + make_path_absolute(path, base_dir)

                break

        updated_flags.append(updated_flag)

    return updated_flags


def strip_flags(flags):
    # Remove leading and trailing spaces from the list of flags.
    return [flag.strip() for flag in flags]

def make_final_flags(filename, flags, base_dir = getcwd(), compiler_flags = ycmconf_default_compiler_flags, flags_filename = None):
    """
    Finalize the given flags for the file of interest. This step
    includes stripping the flags, making them absolute to the given
    base directory and adding the corresponding file type infos to them
    if necessary.
    """ 
    if flags_filename is None:
        flags_filename = filename
    flags = compiler_flags + flags
    if is_c_file(flags_filename):
        flags += ycmconf_c_additional_flags
    elif is_cpp_file(flags_filename):
        flags += ycmconf_cpp_additional_flags
    flags += ycmconf_extra_flags 
    flags = strip_flags(flags)
    ret = {
            "flags": flags, 
            "include_paths_relative_to_dir": base_dir,
            "filename": filename,
            "do_cache": True
    }
    log(ret)
    return ret


def save_add_flags(old_flags, additional_flags):
    """
    Add additional compilation flags to an already existing list of
    compilation flags in a way that no duplication is occurring and no
    conflicting flags are added.

    As the flags which can be passed to clang are not trivial not all cases
    can be catch. However, to simplify things flags expecting an argument
    should either have the argument as next flag or separated by a space. So
    the following examples are valid:

        - "-x", "c++"
        - "-x c++"

    This is not valid and will lead to wrong behavior:

        "-xc++"

    Flags expecting an argument separated by a "=" sign should have them
    directly after the sign. So this is the correct format:

        "-std=c++11"

    :param old_flags: The list of compilation flags which should be extended.
    :type old_flags: list[str]
    :param additional_flags: The list of compilation flags which should be
                             added to the other list.
    :type additional_flags: list[str]
    :rtype: list[str]
    :return: The properly merged result list.
    """
    skip_next_af = False

    for j in range(len(additional_flags)):
        af = additional_flags[j].strip()

        argument_type = "none"
        to_add = True

        if skip_next_af:
            # The current flag is an argument for the previous flag. This
            # should have been added already.
            skip_next_af = False
            continue

        # First check if the flag has an argument as next flag.
        if len(additional_flags) > j + 1 and \
                not additional_flags[j+1].startswith("-"):
            # There is a flag after the current one which does not start with
            # "-". So assume that this is an argument for the current flag.
            argument_type = "next"
            skip_next_af = True

            af_arg = additional_flags[j+1].strip()

        # Next check if the flag has an argument separated by a " ".
        elif af.find(" ") != -1:
            # The argument for the current flag is separated by a space
            # character.
            pos = af.find(" ")

            argument_type = "next"
            af_arg = af[pos+1:].strip()
            af = af[:pos]

        # Next check if the flag has an argument separated by a "=".
        elif af.find("=") != -1:
            # The argument for the current flag is separated by a equal
            # sign.
            pos = af.find("=")

            argument_type = "same"
            af_arg = af[pos+1:].strip()
            af = af[:pos]

        # Check against all flags which are in the already contained in the
        # list.
        skip_next_of = False

        for i in range(len(old_flags)):
            of = old_flags[i].strip()

            if skip_next_of:
                # The current flag is an argument for the previous one. Skip
                # it.
                skip_next_of = False
                continue

            # If there is no argument for this flag, check for simple
            # equality.
            if argument_type == "none":
                if of == af:
                    # The flag is already in the list. So do not add it.
                    to_add = False
                    break

            # The flag is with argument. Check for these cases.

            elif argument_type == "next":
                # The argument is normally given as next argument. So three
                # cases have to be checked:
                #   1. The argument is as next flag given, too.
                #   2. The argument is separated by a space.
                #   3. The argument is directly after the flag.

                # 1
                if of == af:
                    # The flags are the same. So the arguments could be
                    # different. In any case, the additional flag should not
                    # be added.
                    to_add = False
                    skip_next_of = True
                    break

                # 2
                elif of.startswith(af) and of[len(af)] == " ":
                    # The flag is the same and the argument is separated by a
                    # space. Unimportant of the argument the additional flag
                    # should not be added.
                    to_add = False
                    break

                # 3
                elif of.startswith(af):
                    # It could be the same flag with the argument given
                    # directly after the flag or a completely different one.
                    # Anyway don't add the flag to the list.
                    to_add = False
                    break

            elif argument_type == "same":
                # The argument is normally given in the same string separated
                # by an "=" sign. So three cases have to be checked.
                #   1. The argument is in the same string.
                #   2. The argument is in the next flag but the "=" sign in
                #      the current one.
                #   3. The argument is in the next flag as well as the "="
                #      sign.

                # 1 + 2 + 3
                if of.startswith(af):
                    # 1
                    if len(of) > len(af) + 1 and of[len(af)] == "=":
                        # The argument is given directly after the flag
                        # separated by the "=" sign. So don't add the flag
                        # to the list.
                        to_add = False
                        break

                    # 2
                    elif len(of) == len(af) + 1 and of[len(af)] == "=":
                        # The argument is given in the next flag but the "="
                        # is still in the current flag. So don't add the flag
                        # to the list.
                        to_add = False
                        skip_next_of = True
                        break

                    # 3
                    elif len(of) == len(af) and len(old_flags) > i + 1 \
                            and old_flags[i+1].strip().startswith("="):
                        # The argument is given in the next flag and the "="
                        # sign is also in that flag. So don't add the flag to
                        # the list.
                        to_add = False
                        skip_next_of = True
                        break


        # Add the flags if it is not yet contained in the list.
        if to_add:
            if argument_type == "none":
                old_flags.append(af)

            elif argument_type == "next":
                old_flags.extend([af, af_arg])

            elif argument_type == "same":
                old_flags.append("{}={}".format(af, af_arg))


    return old_flags


##
# Methods to create the correct return format wanted by YCM
##

def parse_compile_commands(filename, config):
    """
    Parse the clang compile database generated by cmake. This database
    is normally saved by cmake in a file called "compile_commands.json".
    As we don't want to parse it on our own, functions provided by ycm_core
    are used. The flags corresponding to the file of interest are returned.
    If no information for this file could be found in the database, the
    default flags are used.
    """
    import ycm_core
    database = ycm_core.CompilationDatabase(dirname(config))

    compilation_info = None
    alternative_name = filename
    if is_c_or_cpp_header(filename):
        (name,_) = splitext(filename)

        # Try out all C and CPP extensions for the corresponding source file.
        for ext in (c_source_extensions + cpp_source_extensions):
            alternative_name = name + ext
            if exists(alternative_name):
                continue
            compilation_info = database.GetCompilationInfoForFile(alternative_name)
            break
    elif is_c_or_cpp_source(filename):
        compilation_info = database.GetCompilationInfoForFile(filename)

    if compilation_info is not None and compilation_info.compiler_flags_:
        # We found flags for the file in the database

        # Get compiler flags if possible
        compiler = compilation_info.compiler_flags_[0]
        flags = list( compilation_info.compiler_flags_ )
        compiler_flags = None
        if which(compiler) is not None:
            compiler_flags = get_compiler_flags(compiler, flags)
        if compiler_flags is None:
            compiler_flags = ycmconf_default_compiler_flags

        return make_final_flags(filename, flags, compilation_info.compiler_working_dir_, compiler_flags)

    # We either don't have a proper file ending or did not find any information in the
    # database. Therefor use the default flags.
    return parse_default_flags(filename)


def parse_clang_complete(filename, config):
    with open(config, "r") as config_file:
        flags = config_file.read().splitlines()
        return make_final_flags(filename, flags, dirname(config))


def parse_default_flags(filename):
    """
    Parse and clean the default flags to use them as result for YCM.
    """
    return make_final_flags(filename, ycmconf_default_flags, script_directory())

def c_Settings(kwargs):
    filename = kwargs['filename']

    config = find_file_in_dirs("compile_commands.json", ycmconf_compile_command_search_dirs)
    if config is not None:
        log("compile_commands: " + config)
        return parse_compile_commands(filename, config)

    # config = find_file_recursively(".clang_complete")
    if config is not None:
        log("parse_clang_complete: " + config)
        return parse_clang_complete(filename, config)

    log("parse default flags")
    return parse_default_flags(filename)


####
# Entry point for the YouCompleteMe plugin
####
def Settings(**kwargs):
    if 'client_data' in kwargs:
        defaults_set(kwargs['client_data'])
    
    log("Settings: " + repr(kwargs))
    log("cwd: " + os.getcwd())

    language = kwargs['language']

    if language == "cfamily":
        return c_Settings(kwargs)

    return {}



