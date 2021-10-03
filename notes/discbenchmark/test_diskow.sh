#!/bin/bash
# shellcheck disable=SC1000-SC9999

########################################## functions ##########################

usage() {

}

system_into() {(
	set -x	
	lsb_release -a
 	uname -a
	pacman -Q bonnie++ lvm2 btrfs-progs dosfstools zfs-dkms zfs-tools e2fsprogs
	modinfo zfs | grep -i version
	hwinfo
) 2>&1; }

log() { echo "$(date)" -- "$@" | tee -a $logfile; }

######################################## functions test speed ###################

test_bonnie() {
	local mntpoint="$1"
	pushd $mntpoint
	bonnie++ -u root -g root $mntpoint
	popd
}

test_raw() {
	local disc="$1"
	time sh -c "dd if=/dev/zero of=[PATH] bs=[BLOCK_SIZE]k count=[LOOPS] && sync"
}

test_zcav() {
	local disc="$1"
	zcav $disc
}

######################################### funstions create filesystems #########

test_diskow_zfs() {
	local discs=$@
	trap 'zfs umount tank; zfs destroy -f tank' EXIT
	zpool create tank "$discs"
	zpool status -v tank
	zpool set mountpoint=$mountpoint tank
	zfs mount tank
	zfs list tank

	zfs umount tank
	zpool destroy -f tank
}

########################################### main ###################################

discs=( $1 )
logfile=""
mntpoint="/mnt/testdiskow"
ionice="ionice -c1 "

mkdir -p $mntpoint

shift
run=()
for i in $@; do
	run+=( fs_${i}_init )
done
while read i; do
	run+=( fs_${i}_end )
done <<<"$( ( for i in $@; do echo $i; done; ) | tac )"
echo "${run[@]}"


