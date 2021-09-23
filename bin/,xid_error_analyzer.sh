#!/bin/bash
set -euo pipefail

# Extracted the html page and copied into https://www.convertcsv.com/html-table-to-csv.htm converter
# Then copied here
IFS=',' read -ra g_causes <<<"HW Error,Driver Error,User App Error,System Memory Corruption,Bus Error,Thermal Issue,FB Corruption"
g_xids=$(cat<<EOF
1,Invalid or corrupted push buffer stream,,X,,X,X,,X
2,Invalid or corrupted push buffer stream,,X,,X,X,,X
3,Invalid or corrupted push buffer stream,,X,,X,X,,X
4,Invalid or corrupted push buffer stream,,X,,X,X,,X
,GPU semaphore timeout,,X,X,X,X,,X
5,Unused,,,,,,,
6,Invalid or corrupted push buffer stream,,X,,X,X,,X
7,Invalid or corrupted push buffer address,,X,,,X,,X
8,GPU stopped processing,,X,X,,X,X,
9,Driver error programming GPU,,X,,,,,
10,Unused,,,,,,,
11,Invalid or corrupted push buffer stream,,X,,X,X,,X
12,Driver error handling GPU exception,,X,,,,,
13,Graphics Engine Exception,,X,X,X,X,X,X
14,Unused,,,,,,,
15,Unused,,,,,,,
16,Display engine hung,,X,,,,,
17,Unused,,,,,,,
18,Bus mastering disabled in PCI Config Space,,X,,,,,
19,Display Engine error,,X,,,,,
20,Invalid or corrupted Mpeg push buffer,,X,,X,X,,X
21,Invalid or corrupted Motion Estimation push buffer,,X,,X,X,,X
22,Invalid or corrupted Video Processor push buffer,,X,,X,X,,X
23,Unused,,,,,,,
24,GPU semaphore timeout,,X,X,X,X,X,X
25,Invalid or illegal push buffer stream,,X,X,X,X,,X
26,Framebuffer timeout,,X,,,,,
27,Video processor exception,,X,,,,,
28,Video processor exception,,X,,,,,
29,Video processor exception,,X,,,,,
30,GPU semaphore access error,,X,,,,,
31,GPU memory page fault,,X,X,,,,
32,Invalid or corrupted push buffer stream,,X,,X,X,X,X
33,Internal micro-controller error,,X,,,,,
34,Video processor exception,,X,,,,,
35,Video processor exception,,X,,,,,
36,Video processor exception,,X,,,,,
37,Driver firmware error,,X,,X,X,,
38,Driver firmware error,,X,,,,,
39,Unused,,,,,,,
40,Unused,,,,,,,
41,Unused,,,,,,,
42,Video processor exception,,X,,,,,
43,GPU stopped processing,,X,X,,,,
44,Graphics Engine fault during context switch,,X,,,,,
45,"Preemptive cleanup, due to previous errors -- Most likely to see when running multiple cuda applications and hitting a DBE",,X,,,,,
46,GPU stopped processing,,X,,,,,
47,Video processor exception,,X,,,,,
48,Double Bit ECC Error,X,,,,,,
49,Unused,,,,,,,
50,Unused,,,,,,,
51,Unused,,,,,,,
52,Unused,,,,,,,
53,Unused,,,,,,,
54,Auxiliary power is not connected to the GPU board,,,,,,,
55,Unused,,,,,,,
56,Display Engine error,X,X,,,,,
57,Error programming video memory interface,X,X,,,,,X
58,Unstable video memory interface detected,X,X,,,,,
,EDC error – clarified in printout,X,,,,,,
59,Internal micro-controller error (older drivers),,X,,,,,
60,Video processor exception,,X,,,,,
61,Internal micro-controller breakpoint/warning (newer drivers),,,,,,,
62,Internal micro-controller halt (newer drivers),X,X,,,,X,
63,ECC page retirement recording event,X,X,,,,,X
64,ECC page retirement recording failure,X,X,,,,,
65,Video processor exception,X,X,,,,,
66,Illegal access by driver,,X,X,,,,
67,Illegal access by driver,,X,X,,,,
68,Video processor exception,X,X,,,,,
69,Graphics Engine class error,X,X,,,,,
70,CE3: Unknown Error,X,X,,,,,
71,CE4: Unknown Error,X,X,,,,,
72,CE5: Unknown Error,X,X,,,,,
73,NVENC2 Error,X,X,,,,,
74,NVLINK Error,X,X,,,X,,
75,Reserved,,,,,,,
76,Reserved,,,,,,,
77,Reserved,,,,,,,
78,vGPU Start Error,,X,,,,,
79,GPU has fallen off the bus,X,X,,X,X,X,
80,Corrupted data sent to GPU,X,X,,X,X,,X
81,VGA Subsystem Error,X,,,,,,
82,Reserved,,,,,,,
83,Reserved,,,,,,,
84,Reserved,,,,,,,
85,Reserved,,,,,,,
86,Reserved,,,,,,,
87,Reserved,,,,,,,
88,Reserved,,,,,,,
89,Reserved,,,,,,,
90,Reserved,,,,,,,
91,Reserved,,,,,,,
92,High single-bit ECC error rate,X,X,,,,,
EOF
)
# Copied the html text from the page
g_common=$(cat <<EOF

XID 13: GR: SW Notify Error

This event is logged for general user application faults. Typically this is an out-of-bounds error where the user has walked past the end of an array, but could also be an illegal instruction, illegal register, or other case.

In rare cases, it’s possible for a hardware failure or system software bugs to materialize as XID 13.

When this event is logged, NVIDIA recommends the following:

    Run the application in cuda-gdb or cuda-memcheck , or
    Run the application with CUDA_DEVICE_WAITS_ON_EXCEPTION=1 and then attach later with cuda-gdb, or
    File a bug if the previous two come back inconclusive to eliminate potential NVIDIA driver or hardware bug.

Note: The cuda-memcheck tool instruments the running application and reports which line of code performed the illegal read.

XID 31: Fifo: MMU Error

This event is logged when a fault is reported by the MMU, such as when an illegal address access is made by an applicable unit on the chip Typically these are application-level bugs, but can also be driver bugs or hardware bugs.

When this event is logged, NVIDIA recommends the following:

    Run the application in cuda-gdb or cuda-memcheck , or
    Run the application with CUDA_DEVICE_WAITS_ON_EXCEPTION=1 and then attach later with cuda-gdb, or
    File a bug if the previous two come back inconclusive to eliminate potential NVIDIA driver or hardware bug.

Note: The cuda-memcheck tool instruments the running application and reports which line of code performed the illegal read.

XID 32: PBDMA Error

This event is logged when a fault is reported by the DMA controller which manages the communication stream between the NVIDIA driver and the GPU over the PCI-E bus. These failures primarily involve quality issues on PCI, and are generally not caused by user application actions.

XID 43: RESET CHANNEL VERIF ERROR

This event is logged when a user application hits a software induced fault and must terminate. The GPU remains in a healthy state.

In most cases, this is not indicative of a driver bug but rather a user application error.

XID 45: OS: Preemptive Channel Removal

This event is logged when the user application aborts and the kernel driver tears down the GPU application running on the GPU. Control-C, GPU resets, sigkill are all examples where the application is aborted and this event is created.

In many cases, this is not indicative of a bug but rather a user or system action.

XID 48: DBE (Double Bit Error) ECC Error

This event is logged when the GPU detects that an uncorrectable error occurs on the GPU. This is also reported back to the user application. A GPU reset or node reboot is needed to clear this error.

The tool nvidia-smi can provide a summary of ECC errors. See "Tools That Provide Additional Information About Xid Errors".
EOF
)
get_common() {
	awk -v RS='\nXID ' -v num="$1" '$0 ~ "^"num": "{print RS $0}' <<<"$g_common"
}

#c_cross=$'\E[9m'
#c_notcrossed=$'\E[0m'
c_red=$'\E[91m'
c_reset=$'\E(B\E[m'

fatal() {
	echo "${BASH_SOURCE##*/}: ERROR: $*" >&2
	exit 1
}

run() {
	echo "+" "$@" >&2
	"$@"
}

###############################################################################

args=$(getopt -n "${BASH_SOURCE###*/}" -o ab:d -- "$@")
eval set -- "$args"
jbootargs=(-b 0)
g_usedmesg=false
while (($#)); do
	case "$1" in
	-a) jbootargs=(); ;;
	-b) jbootargs=(-b "$2"); shift; ;;
	-d) g_usedmesg=true; ;;
	--) shift; break; 
	esac
	shift
done

if "$g_usedmesg"; then
	input=$(dmesg -T)
else
	input=$(
		run journalctl -t kernel "${jbootargs[@]}" |
		sed -n 's/^\(.*[^ ]\) \+[^ ]\+ \+kernel: \+/[\1] /p'
	)
fi

if ! input=$(<<<"$input" grep 'NVRM:'); then
	fatal "No lines with NVRM found"
fi
output=""
found=()

cat <<<"$input"
echo

input=$(<<<"$input" sed -n 's/^\[\([^]]*\)\].*NVRM: Xid (\(.*\)): \([0-9]*\), \(.*\)/\1\t\2\t\3\t\4/p')
if [[ -z "$input" ]]; then
	echo "No Xid errors...."
else
	# shellcheck disable=2034
	while IFS=$'\t' read -r date deviceid xid info; do
		if ! err=$(grep "^$xid" <<<"$g_xids"); then continue; fi
		IFS=',' read -ra err <<<"$err"
		desc=${err[1]}
		unset 'err[0]' 'err[1]'
		causes=("${err[@]}")

		output+=$(
			{
				printf "%s\n" "$date" "$xid" "$desc"
				paste <(printf "%s\n" "${causes[@]}") <(printf "%s\n" "${g_causes[@]}") |
				awk '
					BEGIN{
						FS="\t"
						cross="\033[9m"
						notcross="\033[29m"
						red="\033[91m"
						reset="\033(B\033[m"
					}
					/^X\t/{print red $2 reset}
					/^\t/{print red "" reset }
				'
			} | paste -sd$'\t'
		)$'\n'
		found+=("$xid")

	done <<<"$input"
fi

<<<"$output" column -ts $'\t' -o ' | ' \
	-N "Data,Xid,Failure,Causes$c_red$c_reset,$c_red$c_reset,$c_red$c_reset,$c_red$c_reset,$c_red$c_reset,$c_red$c_reset"

if ((${#found[@]})); then
	echo
	printf "%s\n" "${found[@]}" | sort -u |
		while read -r id; do get_common "$id" | fmt; echo; done
fi

exit
###############################################################################

exit
curl -sS 'https://docs.nvidia.com/deploy/xid-errors/index.html#topic_4' > /tmp/1.html
</tmp/1.html xmllint -html -xpath '//table[@class="table"]' - 2>/dev/null >/tmp/2.html
links -width 80 -dump /tmp/2.html > /tmp/3



