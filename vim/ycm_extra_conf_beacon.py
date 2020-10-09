import ycm_core
from os import getcwd
from os.path import abspath, join, isabs, normpath, exists, splitext, \
        dirname, realpath

####
# Global lists for the flags and file detection
####

##
# This is the list of default flags.
##
default_flags = [
    "-Wall",
    "-Wextra",
    "-Wno-unknown-attributes",
    "-Wno-unknown-pragmas",
    "--sysroot=" + 
            getcwd() + "/" +
            "_build_tools/gcc-arm-none-eabi-9-2019-q4-major/arm-none-eabi",
# _build_tools/gcc-arm-none-eabi-9-2019-q4-major/bin/arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb -mabi=aapcs -mfloat-abi=soft -Os -dM -E -x c /dev/null | sed '/^#define \([^ ]*\) *\(.*\)/!d;s//\1=\2/;s/"/\\"/g;s/\([^=]*\)=\(.*\)/"-D\1=\2",/;'
# I do not know how to do it and *cache* it in python, so I just copied it in
    "-D__INLINE=inline",
    "-D__STDC__=1",
    "-D__STDC_VERSION__=201710L",
    "-D__STDC_UTF_16__=1",
    "-D__STDC_UTF_32__=1",
    "-D__STDC_HOSTED__=1",
    "-D__GNUC__=10",
    "-D__GNUC_MINOR__=2",
    "-D__GNUC_PATCHLEVEL__=0",
    "-D__VERSION__=\"10.2.0\"",
    "-D__ATOMIC_RELAXED=0",
    "-D__ATOMIC_SEQ_CST=5",
    "-D__ATOMIC_ACQUIRE=2",
    "-D__ATOMIC_RELEASE=3",
    "-D__ATOMIC_ACQ_REL=4",
    "-D__ATOMIC_CONSUME=1",
    "-D__FINITE_MATH_ONLY__=0",
    "-D__SIZEOF_INT__=4",
    "-D__SIZEOF_LONG__=4",
    "-D__SIZEOF_LONG_LONG__=8",
    "-D__SIZEOF_SHORT__=2",
    "-D__SIZEOF_FLOAT__=4",
    "-D__SIZEOF_DOUBLE__=8",
    "-D__SIZEOF_LONG_DOUBLE__=8",
    "-D__SIZEOF_SIZE_T__=4",
    "-D__CHAR_BIT__=8",
    "-D__BIGGEST_ALIGNMENT__=8",
    "-D__ORDER_LITTLE_ENDIAN__=1234",
    "-D__ORDER_BIG_ENDIAN__=4321",
    "-D__ORDER_PDP_ENDIAN__=3412",
    "-D__BYTE_ORDER__=__ORDER_LITTLE_ENDIAN__",
    "-D__FLOAT_WORD_ORDER__=__ORDER_LITTLE_ENDIAN__",
    "-D__SIZEOF_POINTER__=4",
    "-D__SIZE_TYPE__=unsigned int",
    "-D__PTRDIFF_TYPE__=int",
    "-D__WCHAR_TYPE__=unsigned int",
    "-D__WINT_TYPE__=unsigned int",
    "-D__INTMAX_TYPE__=long long int",
    "-D__UINTMAX_TYPE__=long long unsigned int",
    "-D__CHAR16_TYPE__=short unsigned int",
    "-D__CHAR32_TYPE__=long unsigned int",
    "-D__SIG_ATOMIC_TYPE__=int",
    "-D__INT8_TYPE__=signed char",
    "-D__INT16_TYPE__=short int",
    "-D__INT32_TYPE__=long int",
    "-D__INT64_TYPE__=long long int",
    "-D__UINT8_TYPE__=unsigned char",
    "-D__UINT16_TYPE__=short unsigned int",
    "-D__UINT32_TYPE__=long unsigned int",
    "-D__UINT64_TYPE__=long long unsigned int",
    "-D__INT_LEAST8_TYPE__=signed char",
    "-D__INT_LEAST16_TYPE__=short int",
    "-D__INT_LEAST32_TYPE__=long int",
    "-D__INT_LEAST64_TYPE__=long long int",
    "-D__UINT_LEAST8_TYPE__=unsigned char",
    "-D__UINT_LEAST16_TYPE__=short unsigned int",
    "-D__UINT_LEAST32_TYPE__=long unsigned int",
    "-D__UINT_LEAST64_TYPE__=long long unsigned int",
    "-D__INT_FAST8_TYPE__=int",
    "-D__INT_FAST16_TYPE__=int",
    "-D__INT_FAST32_TYPE__=int",
    "-D__INT_FAST64_TYPE__=long long int",
    "-D__UINT_FAST8_TYPE__=unsigned int",
    "-D__UINT_FAST16_TYPE__=unsigned int",
    "-D__UINT_FAST32_TYPE__=unsigned int",
    "-D__UINT_FAST64_TYPE__=long long unsigned int",
    "-D__INTPTR_TYPE__=int",
    "-D__UINTPTR_TYPE__=unsigned int",
    "-D__GXX_ABI_VERSION=1014",
    "-D__SCHAR_MAX__=0x7f",
    "-D__SHRT_MAX__=0x7fff",
    "-D__INT_MAX__=0x7fffffff",
    "-D__LONG_MAX__=0x7fffffffL",
    "-D__LONG_LONG_MAX__=0x7fffffffffffffffLL",
    "-D__WCHAR_MAX__=0xffffffffU",
    "-D__WCHAR_MIN__=0U",
    "-D__WINT_MAX__=0xffffffffU",
    "-D__WINT_MIN__=0U",
    "-D__PTRDIFF_MAX__=0x7fffffff",
    "-D__SIZE_MAX__=0xffffffffU",
    "-D__SCHAR_WIDTH__=8",
    "-D__SHRT_WIDTH__=16",
    "-D__INT_WIDTH__=32",
    "-D__LONG_WIDTH__=32",
    "-D__LONG_LONG_WIDTH__=64",
    "-D__WCHAR_WIDTH__=32",
    "-D__WINT_WIDTH__=32",
    "-D__PTRDIFF_WIDTH__=32",
    "-D__SIZE_WIDTH__=32",
    "-D__INTMAX_MAX__=0x7fffffffffffffffLL",
    "-D__INTMAX_C(c)=c ## LL",
    "-D__UINTMAX_MAX__=0xffffffffffffffffULL",
    "-D__UINTMAX_C(c)=c ## ULL",
    "-D__INTMAX_WIDTH__=64",
    "-D__SIG_ATOMIC_MAX__=0x7fffffff",
    "-D__SIG_ATOMIC_MIN__=(-__SIG_ATOMIC_MAX__ - 1)",
    "-D__SIG_ATOMIC_WIDTH__=32",
    "-D__INT8_MAX__=0x7f",
    "-D__INT16_MAX__=0x7fff",
    "-D__INT32_MAX__=0x7fffffffL",
    "-D__INT64_MAX__=0x7fffffffffffffffLL",
    "-D__UINT8_MAX__=0xff",
    "-D__UINT16_MAX__=0xffff",
    "-D__UINT32_MAX__=0xffffffffUL",
    "-D__UINT64_MAX__=0xffffffffffffffffULL",
    "-D__INT_LEAST8_MAX__=0x7f",
    "-D__INT8_C(c)=c",
    "-D__INT_LEAST8_WIDTH__=8",
    "-D__INT_LEAST16_MAX__=0x7fff",
    "-D__INT16_C(c)=c",
    "-D__INT_LEAST16_WIDTH__=16",
    "-D__INT_LEAST32_MAX__=0x7fffffffL",
    "-D__INT32_C(c)=c ## L",
    "-D__INT_LEAST32_WIDTH__=32",
    "-D__INT_LEAST64_MAX__=0x7fffffffffffffffLL",
    "-D__INT64_C(c)=c ## LL",
    "-D__INT_LEAST64_WIDTH__=64",
    "-D__UINT_LEAST8_MAX__=0xff",
    "-D__UINT8_C(c)=c",
    "-D__UINT_LEAST16_MAX__=0xffff",
    "-D__UINT16_C(c)=c",
    "-D__UINT_LEAST32_MAX__=0xffffffffUL",
    "-D__UINT32_C(c)=c ## UL",
    "-D__UINT_LEAST64_MAX__=0xffffffffffffffffULL",
    "-D__UINT64_C(c)=c ## ULL",
    "-D__INT_FAST8_MAX__=0x7fffffff",
    "-D__INT_FAST8_WIDTH__=32",
    "-D__INT_FAST16_MAX__=0x7fffffff",
    "-D__INT_FAST16_WIDTH__=32",
    "-D__INT_FAST32_MAX__=0x7fffffff",
    "-D__INT_FAST32_WIDTH__=32",
    "-D__INT_FAST64_MAX__=0x7fffffffffffffffLL",
    "-D__INT_FAST64_WIDTH__=64",
    "-D__UINT_FAST8_MAX__=0xffffffffU",
    "-D__UINT_FAST16_MAX__=0xffffffffU",
    "-D__UINT_FAST32_MAX__=0xffffffffU",
    "-D__UINT_FAST64_MAX__=0xffffffffffffffffULL",
    "-D__INTPTR_MAX__=0x7fffffff",
    "-D__INTPTR_WIDTH__=32",
    "-D__UINTPTR_MAX__=0xffffffffU",
    "-D__GCC_IEC_559=0",
    "-D__GCC_IEC_559_COMPLEX=0",
    "-D__FLT_EVAL_METHOD__=0",
    "-D__FLT_EVAL_METHOD_TS_18661_3__=0",
    "-D__DEC_EVAL_METHOD__=2",
    "-D__FLT_RADIX__=2",
    "-D__FLT_MANT_DIG__=24",
    "-D__FLT_DIG__=6",
    "-D__FLT_MIN_EXP__=(-125)",
    "-D__FLT_MIN_10_EXP__=(-37)",
    "-D__FLT_MAX_EXP__=128",
    "-D__FLT_MAX_10_EXP__=38",
    "-D__FLT_DECIMAL_DIG__=9",
    "-D__FLT_MAX__=3.4028234663852886e+38F",
    "-D__FLT_NORM_MAX__=3.4028234663852886e+38F",
    "-D__FLT_MIN__=1.1754943508222875e-38F",
    "-D__FLT_EPSILON__=1.1920928955078125e-7F",
    "-D__FLT_DENORM_MIN__=1.4012984643248171e-45F",
    "-D__FLT_HAS_DENORM__=1",
    "-D__FLT_HAS_INFINITY__=1",
    "-D__FLT_HAS_QUIET_NAN__=1",
    "-D__DBL_MANT_DIG__=53",
    "-D__DBL_DIG__=15",
    "-D__DBL_MIN_EXP__=(-1021)",
    "-D__DBL_MIN_10_EXP__=(-307)",
    "-D__DBL_MAX_EXP__=1024",
    "-D__DBL_MAX_10_EXP__=308",
    "-D__DBL_DECIMAL_DIG__=17",
    "-D__DBL_MAX__=((double)1.7976931348623157e+308L)",
    "-D__DBL_NORM_MAX__=((double)1.7976931348623157e+308L)",
    "-D__DBL_MIN__=((double)2.2250738585072014e-308L)",
    "-D__DBL_EPSILON__=((double)2.2204460492503131e-16L)",
    "-D__DBL_DENORM_MIN__=((double)4.9406564584124654e-324L)",
    "-D__DBL_HAS_DENORM__=1",
    "-D__DBL_HAS_INFINITY__=1",
    "-D__DBL_HAS_QUIET_NAN__=1",
    "-D__LDBL_MANT_DIG__=53",
    "-D__LDBL_DIG__=15",
    "-D__LDBL_MIN_EXP__=(-1021)",
    "-D__LDBL_MIN_10_EXP__=(-307)",
    "-D__LDBL_MAX_EXP__=1024",
    "-D__LDBL_MAX_10_EXP__=308",
    "-D__DECIMAL_DIG__=17",
    "-D__LDBL_DECIMAL_DIG__=17",
    "-D__LDBL_MAX__=1.7976931348623157e+308L",
    "-D__LDBL_NORM_MAX__=1.7976931348623157e+308L",
    "-D__LDBL_MIN__=2.2250738585072014e-308L",
    "-D__LDBL_EPSILON__=2.2204460492503131e-16L",
    "-D__LDBL_DENORM_MIN__=4.9406564584124654e-324L",
    "-D__LDBL_HAS_DENORM__=1",
    "-D__LDBL_HAS_INFINITY__=1",
    "-D__LDBL_HAS_QUIET_NAN__=1",
    "-D__FLT32_MANT_DIG__=24",
    "-D__FLT32_DIG__=6",
    "-D__FLT32_MIN_EXP__=(-125)",
    "-D__FLT32_MIN_10_EXP__=(-37)",
    "-D__FLT32_MAX_EXP__=128",
    "-D__FLT32_MAX_10_EXP__=38",
    "-D__FLT32_DECIMAL_DIG__=9",
    "-D__FLT32_MAX__=3.4028234663852886e+38F32",
    "-D__FLT32_NORM_MAX__=3.4028234663852886e+38F32",
    "-D__FLT32_MIN__=1.1754943508222875e-38F32",
    "-D__FLT32_EPSILON__=1.1920928955078125e-7F32",
    "-D__FLT32_DENORM_MIN__=1.4012984643248171e-45F32",
    "-D__FLT32_HAS_DENORM__=1",
    "-D__FLT32_HAS_INFINITY__=1",
    "-D__FLT32_HAS_QUIET_NAN__=1",
    "-D__FLT64_MANT_DIG__=53",
    "-D__FLT64_DIG__=15",
    "-D__FLT64_MIN_EXP__=(-1021)",
    "-D__FLT64_MIN_10_EXP__=(-307)",
    "-D__FLT64_MAX_EXP__=1024",
    "-D__FLT64_MAX_10_EXP__=308",
    "-D__FLT64_DECIMAL_DIG__=17",
    "-D__FLT64_MAX__=1.7976931348623157e+308F64",
    "-D__FLT64_NORM_MAX__=1.7976931348623157e+308F64",
    "-D__FLT64_MIN__=2.2250738585072014e-308F64",
    "-D__FLT64_EPSILON__=2.2204460492503131e-16F64",
    "-D__FLT64_DENORM_MIN__=4.9406564584124654e-324F64",
    "-D__FLT64_HAS_DENORM__=1",
    "-D__FLT64_HAS_INFINITY__=1",
    "-D__FLT64_HAS_QUIET_NAN__=1",
    "-D__FLT32X_MANT_DIG__=53",
    "-D__FLT32X_DIG__=15",
    "-D__FLT32X_MIN_EXP__=(-1021)",
    "-D__FLT32X_MIN_10_EXP__=(-307)",
    "-D__FLT32X_MAX_EXP__=1024",
    "-D__FLT32X_MAX_10_EXP__=308",
    "-D__FLT32X_DECIMAL_DIG__=17",
    "-D__FLT32X_MAX__=1.7976931348623157e+308F32x",
    "-D__FLT32X_NORM_MAX__=1.7976931348623157e+308F32x",
    "-D__FLT32X_MIN__=2.2250738585072014e-308F32x",
    "-D__FLT32X_EPSILON__=2.2204460492503131e-16F32x",
    "-D__FLT32X_DENORM_MIN__=4.9406564584124654e-324F32x",
    "-D__FLT32X_HAS_DENORM__=1",
    "-D__FLT32X_HAS_INFINITY__=1",
    "-D__FLT32X_HAS_QUIET_NAN__=1",
    "-D__SFRACT_FBIT__=7",
    "-D__SFRACT_IBIT__=0",
    "-D__SFRACT_MIN__=(-0.5HR-0.5HR)",
    "-D__SFRACT_MAX__=0X7FP-7HR",
    "-D__SFRACT_EPSILON__=0x1P-7HR",
    "-D__USFRACT_FBIT__=8",
    "-D__USFRACT_IBIT__=0",
    "-D__USFRACT_MIN__=0.0UHR",
    "-D__USFRACT_MAX__=0XFFP-8UHR",
    "-D__USFRACT_EPSILON__=0x1P-8UHR",
    "-D__FRACT_FBIT__=15",
    "-D__FRACT_IBIT__=0",
    "-D__FRACT_MIN__=(-0.5R-0.5R)",
    "-D__FRACT_MAX__=0X7FFFP-15R",
    "-D__FRACT_EPSILON__=0x1P-15R",
    "-D__UFRACT_FBIT__=16",
    "-D__UFRACT_IBIT__=0",
    "-D__UFRACT_MIN__=0.0UR",
    "-D__UFRACT_MAX__=0XFFFFP-16UR",
    "-D__UFRACT_EPSILON__=0x1P-16UR",
    "-D__LFRACT_FBIT__=31",
    "-D__LFRACT_IBIT__=0",
    "-D__LFRACT_MIN__=(-0.5LR-0.5LR)",
    "-D__LFRACT_MAX__=0X7FFFFFFFP-31LR",
    "-D__LFRACT_EPSILON__=0x1P-31LR",
    "-D__ULFRACT_FBIT__=32",
    "-D__ULFRACT_IBIT__=0",
    "-D__ULFRACT_MIN__=0.0ULR",
    "-D__ULFRACT_MAX__=0XFFFFFFFFP-32ULR",
    "-D__ULFRACT_EPSILON__=0x1P-32ULR",
    "-D__LLFRACT_FBIT__=63",
    "-D__LLFRACT_IBIT__=0",
    "-D__LLFRACT_MIN__=(-0.5LLR-0.5LLR)",
    "-D__LLFRACT_MAX__=0X7FFFFFFFFFFFFFFFP-63LLR",
    "-D__LLFRACT_EPSILON__=0x1P-63LLR",
    "-D__ULLFRACT_FBIT__=64",
    "-D__ULLFRACT_IBIT__=0",
    "-D__ULLFRACT_MIN__=0.0ULLR",
    "-D__ULLFRACT_MAX__=0XFFFFFFFFFFFFFFFFP-64ULLR",
    "-D__ULLFRACT_EPSILON__=0x1P-64ULLR",
    "-D__SACCUM_FBIT__=7",
    "-D__SACCUM_IBIT__=8",
    "-D__SACCUM_MIN__=(-0X1P7HK-0X1P7HK)",
    "-D__SACCUM_MAX__=0X7FFFP-7HK",
    "-D__SACCUM_EPSILON__=0x1P-7HK",
    "-D__USACCUM_FBIT__=8",
    "-D__USACCUM_IBIT__=8",
    "-D__USACCUM_MIN__=0.0UHK",
    "-D__USACCUM_MAX__=0XFFFFP-8UHK",
    "-D__USACCUM_EPSILON__=0x1P-8UHK",
    "-D__ACCUM_FBIT__=15",
    "-D__ACCUM_IBIT__=16",
    "-D__ACCUM_MIN__=(-0X1P15K-0X1P15K)",
    "-D__ACCUM_MAX__=0X7FFFFFFFP-15K",
    "-D__ACCUM_EPSILON__=0x1P-15K",
    "-D__UACCUM_FBIT__=16",
    "-D__UACCUM_IBIT__=16",
    "-D__UACCUM_MIN__=0.0UK",
    "-D__UACCUM_MAX__=0XFFFFFFFFP-16UK",
    "-D__UACCUM_EPSILON__=0x1P-16UK",
    "-D__LACCUM_FBIT__=31",
    "-D__LACCUM_IBIT__=32",
    "-D__LACCUM_MIN__=(-0X1P31LK-0X1P31LK)",
    "-D__LACCUM_MAX__=0X7FFFFFFFFFFFFFFFP-31LK",
    "-D__LACCUM_EPSILON__=0x1P-31LK",
    "-D__ULACCUM_FBIT__=32",
    "-D__ULACCUM_IBIT__=32",
    "-D__ULACCUM_MIN__=0.0ULK",
    "-D__ULACCUM_MAX__=0XFFFFFFFFFFFFFFFFP-32ULK",
    "-D__ULACCUM_EPSILON__=0x1P-32ULK",
    "-D__LLACCUM_FBIT__=31",
    "-D__LLACCUM_IBIT__=32",
    "-D__LLACCUM_MIN__=(-0X1P31LLK-0X1P31LLK)",
    "-D__LLACCUM_MAX__=0X7FFFFFFFFFFFFFFFP-31LLK",
    "-D__LLACCUM_EPSILON__=0x1P-31LLK",
    "-D__ULLACCUM_FBIT__=32",
    "-D__ULLACCUM_IBIT__=32",
    "-D__ULLACCUM_MIN__=0.0ULLK",
    "-D__ULLACCUM_MAX__=0XFFFFFFFFFFFFFFFFP-32ULLK",
    "-D__ULLACCUM_EPSILON__=0x1P-32ULLK",
    "-D__QQ_FBIT__=7",
    "-D__QQ_IBIT__=0",
    "-D__HQ_FBIT__=15",
    "-D__HQ_IBIT__=0",
    "-D__SQ_FBIT__=31",
    "-D__SQ_IBIT__=0",
    "-D__DQ_FBIT__=63",
    "-D__DQ_IBIT__=0",
    "-D__TQ_FBIT__=127",
    "-D__TQ_IBIT__=0",
    "-D__UQQ_FBIT__=8",
    "-D__UQQ_IBIT__=0",
    "-D__UHQ_FBIT__=16",
    "-D__UHQ_IBIT__=0",
    "-D__USQ_FBIT__=32",
    "-D__USQ_IBIT__=0",
    "-D__UDQ_FBIT__=64",
    "-D__UDQ_IBIT__=0",
    "-D__UTQ_FBIT__=128",
    "-D__UTQ_IBIT__=0",
    "-D__HA_FBIT__=7",
    "-D__HA_IBIT__=8",
    "-D__SA_FBIT__=15",
    "-D__SA_IBIT__=16",
    "-D__DA_FBIT__=31",
    "-D__DA_IBIT__=32",
    "-D__TA_FBIT__=63",
    "-D__TA_IBIT__=64",
    "-D__UHA_FBIT__=8",
    "-D__UHA_IBIT__=8",
    "-D__USA_FBIT__=16",
    "-D__USA_IBIT__=16",
    "-D__UDA_FBIT__=32",
    "-D__UDA_IBIT__=32",
    "-D__UTA_FBIT__=64",
    "-D__UTA_IBIT__=64",
    "-D__REGISTER_PREFIX__=",
    "-D__USER_LABEL_PREFIX__=",
    "-D__GNUC_STDC_INLINE__=1",
    "-D__NO_INLINE__=1",
    "-D__CHAR_UNSIGNED__=1",
    "-D__GCC_ATOMIC_BOOL_LOCK_FREE=1",
    "-D__GCC_ATOMIC_CHAR_LOCK_FREE=1",
    "-D__GCC_ATOMIC_CHAR16_T_LOCK_FREE=1",
    "-D__GCC_ATOMIC_CHAR32_T_LOCK_FREE=1",
    "-D__GCC_ATOMIC_WCHAR_T_LOCK_FREE=1",
    "-D__GCC_ATOMIC_SHORT_LOCK_FREE=1",
    "-D__GCC_ATOMIC_INT_LOCK_FREE=1",
    "-D__GCC_ATOMIC_LONG_LOCK_FREE=1",
    "-D__GCC_ATOMIC_LLONG_LOCK_FREE=1",
    "-D__GCC_ATOMIC_TEST_AND_SET_TRUEVAL=1",
    "-D__GCC_ATOMIC_POINTER_LOCK_FREE=1",
    "-D__HAVE_SPECULATION_SAFE_VALUE=1",
    "-D__PRAGMA_REDEFINE_EXTNAME=1",
    "-D__SIZEOF_WCHAR_T__=4",
    "-D__SIZEOF_WINT_T__=4",
    "-D__SIZEOF_PTRDIFF_T__=4",
    "-D__ARM_32BIT_STATE=1",
    "-D__ARM_SIZEOF_MINIMAL_ENUM=1",
    "-D__ARM_SIZEOF_WCHAR_T=4",
    "-D__arm__=1",
    "-D__ARM_ARCH=4",
    "-D__ARM_ARCH_ISA_ARM=1",
    "-D__APCS_32__=1",
    "-D__GCC_ASM_FLAG_OUTPUTS__=1",
    "-D__ARM_ARCH_ISA_THUMB=1",
    "-D__ARMEL__=1",
    "-D__SOFTFP__=1",
    "-D__VFP_FP__=1",
    "-D__THUMB_INTERWORK__=1",
    "-D__ARM_ARCH_4T__=1",
    "-D__ARM_PCS=1",
    "-D__ARM_EABI__=1",
    "-D__ARM_FEATURE_COPROC=1",
    "-D__GXX_TYPEINFO_EQUALITY_INLINE=0",
    "-D__ELF__=1",
    "-D__USES_INITFINI__=1"
]

##
# C header extensions
##
c_header_extensions = [
    ".h",
]

##
# C source extensions
##
c_source_extensions = [
    ".c",
]

##
# C additional flags
##
c_additional_flags = [
    # Tell clang that this is a C file.
    "-x","c",
    # Use the latest standard if possible.
    "-std=gnu11",
]

##
# CPP header extensions
##
cpp_header_extensions = [
    ".hh",
    ".H",
    ".hp",
    ".hpp",
    ".HPP",
    ".hxx",
    ".h++",
]

##
# CPP source extensions
##
cpp_source_extensions = [
    ".cp",
    ".cpp",
    ".CPP",
    ".cc",
    ".C",
    ".cxx",
    ".c++",
]

##
# CPP additional flags
##
cpp_additional_flags = [
    # Tell clang that this file is a CPP file.
    "-x","c++",
    # Use the latest standard if possible.
    "-std=gnu++17",
]


####
# Helper functions
####

##
# Methods for file system interaction
##

def log(what):
    open("/tmp/ycmd_dupa", "a").write("AAAAA " + repr(what) + "\n")

def find_file_recursively(file_name, start_dir = getcwd(), stop_dir = None):
    """
    This method will walk trough the directory tree upwards
    starting at the given directory searching for a file with
    the given name.

    :param file_name: The name of the file of interest. Make sure
                      it does not contain any path information.
    :type file_name: str
    :param start_dir: The directory where the search should start.
                      If it is omitted, the cwd is used.
    :type start_dir: str
    :param stop_dir: The directory where the search should stop. If
                     this is omitted, it will stop at the root directory.
    :type stop_dir: str
    :rtype: str
    :return: The file path where the file was first found.
    """
    cur_dir = abspath(start_dir) if not isabs(start_dir) else start_dir

    while True:
        if exists(join(cur_dir, file_name)):
            # The file of interest exists in the current directory
            # so return it.
            return join(cur_dir, file_name)

        # The file was not found yet so try in the parent directory.
        parent_dir = dirname(cur_dir)

        if parent_dir == cur_dir or parent_dir == stop_dir:
            # We are either at the root directory or reached the stop
            # directory.
            return None
        else:
            cur_dir = parent_dir


def file_exists(file_name, start_dir = getcwd()):
    """
    Checks whether a file with the given file name exists in any parent
    folder of the given directory.

    :param file_name: The name of the file of interest.
    :type file_name: str
    :param start_dir: The directory where to start searching. If omitted the
                      cwd is used.
    :type start_dir: str
    :rtype: bool
    :return: True if the file was found or False if not.
    """
    return find_file_recursively(file_name, start_dir) is not None


def make_path_absolute(path, base_dir=getcwd()):
    """
    Make a given path absolute using the given base directory if it is
    not already absolute.

    :param path: The path of interest.
    :type path: str
    :param base_dir: The directory which should be used to make the
                     path absolute. If it is omitted the cwd is used.
    :type base_dir: str
    :rtype: str
    :return: The absolute path.
    """
    if isabs(path):
        return path
    else:
        return join(base_dir, path)


def script_directory():
    """
    Returns the directory where the current script is located.

    :rtype: str
    :return: The directory where the current script is located.
    """
    return dirname(__file__)


##
# Methods to check for the different source file types
##

def is_header(file_path):
    """
    Checks if the given file is a header file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a header or False if not.
    """
    return is_c_header(file_path) or is_cpp_header(file_path)


def is_c_header(file_path):
    """
    Checks if the given file is a C header file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a C header or False if not.
    """
    (_, extension) = splitext(file_path)

    return extension in c_header_extensions


def is_cpp_header(file_path):
    """
    Checks if the given file is a CPP header file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a CPP header or False if not.
    """
    (_, extension) = splitext(file_path)

    return extension in cpp_header_extensions


def is_source(file_path):
    """
    Checks if the given file is a source file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a source file or False if not.
    """
    return is_c_source(file_path) or is_cpp_source(file_path)


def is_c_source(file_path):
    """
    Checks if the given file is a C source file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a C source file or False if not.
    """
    (_, extension) = splitext(file_path)

    return extension in c_source_extensions


def is_cpp_source(file_path):
    """
    Checks if the given file is a CPP source file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a CPP source file or False if not.
    """
    (_, extension) = splitext(file_path)

    return extension in cpp_source_extensions


def is_c_file(file_path):
    """
    Checks if the given file is a C file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a C file or False if not.
    """
    return is_c_source(file_path) or is_c_header(file_path)


def is_cpp_file(file_path):
    """
    Checks if the given file is a CPP file or not.

    :param file_path: The path to the file of interest.
    :type file_path: str
    :rtype: bool
    :return: True if the file is a CPP file or False if not.
    """
    return is_cpp_source(file_path) or is_cpp_header(file_path)


##
# Methods to manipulate the compilation flags
##

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
    """
    Remove leading and trailing spaces from the list of flags.

    :param flags: The list of flags which should be stripped.
    :type flags: list[str]
    :rtype: list[str]
    :return: The list of flags with leading and trailing spaces removed.
    """
    return [flag.strip() for flag in flags]


def make_final_flags(file_name, flags, base_dir = getcwd()):
    """
    Finalize the given flags for the file of interest. This step
    includes stripping the flags, making them absolute to the given
    base directory and adding the corresponding file type infos to them
    if necessary.

    :param file_name: The name of the file of interest.
    :type file_name: str
    :param flags: The flags which have been collected so far for the file.
    :type flags: list[str]
    :param base_dir: The directory which should be used to make the flags
                     absolute. If this is omitted the cwd is used.
    :type base_dir: str
    :rtype: dict[str,object]
    :return: The finalized flags for the file in the format wanted by YCM.
    """
    stripped = strip_flags(flags)
    absolute = make_absolute_flags(stripped, base_dir)

    final = absolute
    if is_c_file(file_name):
        final = save_add_flags(absolute, c_additional_flags)
    if is_cpp_file(file_name):
        final = save_add_flags(absolute, cpp_additional_flags)

    return create_result(final)


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

def create_result(flags, do_cache = True, **kwargs):
    """
    Create the correct return value for YCM.

    :param flags: The flags for the requested file.
    :type flags: list[str]
    :param do_cache: If the result should be cached by YCM or not. If this is
                     omitted True is used.
    :type do_cache: bool
    :param kwargs: Additional arguments.
    :type kwargs: dict[str,object]
    :rtype: dict[str,object]
    :return: A dictionary in the format wanted by YCM.
    """
    ret = {"flags": flags, "do_cache": do_cache}

    return dict(ret, **kwargs)


def merge_lists(l1, l2):
    tmp = l1
    for i in l2:
        tmp.append(i)
    return tmp

def parse_compile_commands(file_name, search_base = getcwd()):
    """
    Parse the clang compile database generated by cmake. This database
    is normally saved by cmake in a file called "compile_commands.json".
    As we don't want to parse it on our own, functions provided by ycm_core
    are used. The flags corresponding to the file of interest are returned.
    If no information for this file could be found in the database, the
    default flags are used.

    :param file_name: The file for which flags should be created.
    :type file_name: str
    :param search_base: The directory at which the search for the database
                        file should start. If it is omitted the cwd is used.
    :type search_base: str
    :rtype: dict[str,object]
    :returns: The flags found in the database in the format wanted by YCM.
    """
    database_path = dirname(find_file_recursively("compile_commands.json",
            search_base))

    database = ycm_core.CompilationDatabase(database_path)

    # As headers are not in the database, we have to use the corresponding
    # source file.
    if is_header(file_name):
        (name,_) = splitext(file_name)

        # Try out all C and CPP extensions for the corresponding source file.
        for ext in (c_source_extensions + cpp_source_extensions):
            alternative_name = name + ext

            if exists(alternative_name):
                compilation_info = database.GetCompilationInfoForFile(alternative_name)

                # In the database we found flags for the alternative name
                if (compilation_info.compiler_flags_):
                    tmp = merge_lists(compilation_info.compiler_flags_, default_flags)
                    return make_final_flags(file_name, tmp,
                            compilation_info.compiler_working_dir_)

    elif is_source(file_name):
        compilation_info = database.GetCompilationInfoForFile(file_name)

        # We found flags for the file in the database
        if (compilation_info.compiler_flags_):
            tmp = merge_lists(compilation_info.compiler_flags_, default_flags)
            return make_final_flags(file_name, tmp,
                    compilation_info.compiler_working_dir_)

    # We either don't have a proper file ending or did not find any information in the
    # database. Therefor use the default flags.
    return parse_default_flags(file_name)


def parse_clang_complete(file_name, search_base = getcwd()):
    """
    Parse the configuration file for the clang complete VIM plugin.
    Therefore it looks for a ".clang_complete" file starting at the
    given directory.

    :param file_name: The file for which flags should be created.
    :type file_name: str
    :param search_base: The directory where to start with the search for
                        the configuration file. If it is omitted the cwd is
                        used.
    :type search_base: str
    :rtype: dict[str,object]
    :returns: The flags found in the file in the format wanted by YCM.
    """
    config = find_file_recursively(".clang_complete", search_base)
    config_path = dirname(config)

    with open(config, "r") as config_file:
        flags = config_file.read().splitlines()

        return make_final_flags(file_name, flags, config_path)


def parse_default_flags(file_name):
    """
    Parse and clean the default flags to use them as result for YCM.

    :param file_name: The file for which flags should be created.
    :type file_name: str
    :rtype: dict[str,object]
    :returns: The default flags in the format wanted by YCM.
    """
    return make_final_flags(file_name, default_flags, script_directory())


####
# Entry point for the YouCompleteMe plugin
####

def Settings(**kwargs):
    """
    This method is the entry point for the YCM plugin. It is called by the
    plugin to get the all necessary compiler flags to parse a specific file
    given as argument.

    :param filename: The path to the file for which YouCompleteMe likes to do
                      auto completion.
    :type filename: str
    :param kwargs: Additional key word arguments.
    :type kwargs: dict[str,str]
    :rtype: dict[str,object]
    :return: The compilation flags for the file in the format wanted by YCM.
    """
    # First check for a compile_commands.json file.
    search_base = getcwd() + "/_build/cmake/"

    filename = kwargs['filename']
    language = kwargs['language']
    if language != "cfamily":
        raise Exception(language)
        return {}

    if file_exists("compile_commands.json", search_base):
        # There exists a compile_commands.json file. Try to use this one.
        return parse_compile_commands(filename, search_base)
    elif file_exists(".clang_complete", search_base):
        # There exists a .clang_complete file. Try to use this one.
        return parse_clang_complete(filename, search_base)
    else:
        # No files exists. Use the default flags.
        return parse_default_flags(filename)

