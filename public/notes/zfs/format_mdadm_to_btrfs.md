# zfs
## init

for i in 1 2 3; do
	dd if=/dev/zero of=/tmp/testdisc$1 bs=1M count=200
	losetup /dev/loop$i /tmp/testdisc$1
done

## check

for i in 1 2 3; do dd if=/dev/urandom of=dupa$i count=200 bs=1M; done
md5sum /tmp/mountpoint/* > /tmp/md5sumountpoint

echo -ne "$(md5sum /tmp/mountpoint/*)""\n""$(cat /tmp/md5sumountpoint)"

## mdadm

mdadm --create mdtest --raid-devices=2 -l 1 --metadata=0.90 /dev/loop1 /dev/loop3
mkfs.ext4 /dev/md/mdtest
mount /dev/md/mdtest ./mountpoint/

mdadm --manage mdtest --fail /dev/loop3
mdadm --manage /dev/md/mdtest --remove /dev/loop3
mdadm --manage /dev/md/mdtest --add /dev/loop3

## btrfs

mkfs.btrfs -d raid1 -m raid1 /dev/loop1 /dev/loop3 -f -L test
mount /dev/loop1 ./mountpoint
pushd mountpoint
btrfs balance start -{d,m}convert=single -vf .
btrfs balance start -{d,m}usage=0 -vf --full-balance .
btrfs balance start -{d,m}convert=single -vf .
btrfs scrub start .
btrfs balance start -{d,m}usage=0 -vf --full-balance .
btrfs device remove /dev/loop3 .
btrfs scrub start .
btrfs device add /dev/loop3 .
btrfs scrub start .
btrfs balance start -{d,m}usage=0 -vf --full-balance .
btrfs balance start -{d,m}convert=raid1 -vf --full-balance .
btrfs device delete missing .

## zfs

zpool create -f -o ashift=12 zroot mirror /dev/loop1 /dev/loop3
zfs set atime=on zroot
zfs set relatime=on zroot
zfs set compression=on zroot
zfs set mountpoint=legacy zroot
zfs set mountpoint=/tmp/mountpoint zroot
zfs mount
zpool offline zroot /dev/loop3
zpool online zroot /dev/loop3

## zfs what did

# zfs create with missing disc
d=/dev/disk/by-id/ata-ST3500320AS_6QM0NX3Y-part6
dsize=$(blockdev --getsize64 $d)
truncate -s $(( dsize+1000 )) /tmp/missing
zpool create -o ashift=12 leoroot mirror $d /tmp/missing

zpool offline leoroot /tmp/missing
rm /tmp/missing

zfs set atime=on leoroot
zfs set relatime=on leoroot
zfs set compression=on leoroot

zfs set mountpoint=/ leoroot
zfs create leoroot/home -o mountpoint=/home
zfs create leoroot/archive -o mountpoint=/home/archive -o compression=gzip-7
zfs create leoroot/var -o mountpoint=/var -o xattr=sa -o acltype=posixacl
zpool set cachefile=/etc/zfs/zpool.cache leoroot

zpool export leoroot

mount=/mnt/temp1
zpool import -d /dev/mapper/ -R "$mount" leoroot


## zfs 10.sty.2016
```

# zpool create \
	>         -o ashift=12 \
	>         -o feature@async_destroy=enabled -o feature@empty_bpobj=enabled \
	>         -o feature@lz4_compress=enabled -o feature@spacemap_histogram=enabled \
	>         -o feature@enabled_txg=enabled leoroot mirror $d /tmp/missing

0 leonidas ~
# zpool get all
NAME     PROPERTY                    VALUE                       SOURCE
leoroot  size                        456G                        -
leoroot  capacity                    0%                          -
leoroot  altroot                     -                           default
leoroot  health                      ONLINE                      -
leoroot  guid                        11531448030690600465        default
leoroot  version                     -                           default
leoroot  bootfs                      -                           default
leoroot  delegation                  on                          default
leoroot  autoreplace                 off                         default
leoroot  cachefile                   -                           default
leoroot  failmode                    wait                        default
leoroot  listsnapshots               off                         default
leoroot  autoexpand                  off                         default
leoroot  dedupditto                  0                           default
leoroot  dedupratio                  1.00x                       -
leoroot  free                        456G                        -
leoroot  allocated                   50K                         -
leoroot  readonly                    off                         -
leoroot  ashift                      0                           default
leoroot  comment                     -                           default
leoroot  expandsize                  -                           -
leoroot  freeing                     0                           default
leoroot  fragmentation               0%                          -
leoroot  leaked                      0                           default
leoroot  feature@async_destroy       enabled                     local
leoroot  feature@empty_bpobj         enabled                     local
leoroot  feature@lz4_compress        active                      local
leoroot  feature@spacemap_histogram  active                      local
leoroot  feature@enabled_txg         active                      local
leoroot  feature@hole_birth          active                      local
leoroot  feature@extensible_dataset  enabled                     local
leoroot  feature@embedded_data       active                      local
leoroot  feature@bookmarks           enabled                     local
leoroot  feature@filesystem_limits   enabled                     local
leoroot  feature@large_blocks        enabled                     local
```
###

