Device     Boot    Start       End   Sectors   Size Id Type
/dev/sda1  *        2048   1953791   1951744   953M 83 Linux
/dev/sda2        1953792  10156031   8202240   3.9G 82 Linux swap / Solaris
/dev/sda3       10156032 629143551 618987520 295.2G 83 Linux


1. `resize2fs -p /dev/sda3 138G`
  1. `Resizing the filesystem on /dev/sda3 to 36175872 (4k) blocks`
  2. `36175872 * 4096 = 148176371712` - wielkość partycji w bajtach
2. Create partition on the end of harddrive with same size
  1. `fdisk /dev/sda`
  2. `148176371712 / 512 = 289406976` - wielkość partycji w sektorach po 512 bajtów
  3. `629145600` - wielkość całego dysku w sektorach
  4. `629145600 - 289406976 = 339738624` - początek partycji od końca
  5. `d 3`
  6. `n p 3 \n 289406976`
  7. `n p 4 339738624 629145599`
4. `e2fsck -f /dev/sda3`
3. `resize2fs -p /dev/sda3`
5. Copy new partition
    1. `pv < /dev/sda3 > /dev/sda4` the new partition
4. `e2fsck -f /dev/sda4`
5. Resize `/dev/sda3` to max
  6. `d 3`
  7. `p 3 \n \n \n`
6. Format zfs
```
zpool create -f -o ashift=12         \
             -O acltype=posixacl       \
             -O relatime=on            \
             -O xattr=sa               \
             -O dnodesize=legacy       \
             -O normalization=formD    \
             -O mountpoint=none        \
             -O canmount=off           \
             -O devices=off            \
             -O autoexpand=on          \
             -R /mnt                   \
             zperun /dev/sda3
zfs create -o mountpoint=/                 -o canmount=noauto zperun/root
zfs create -o mountpoint=/root             -o canmount=on     zperun/root/root
zfs create -o mountpoint=/var              -o canmount=on     zperun/root/var
zfs create -o mountpoint=/var/lib/docker   -o canmount=on     zperun/root/var/docker
zfs create -o mountpoint=/home             -o canmount=on     zperun/root/home
zfs create -o mountpoint=/home/share/share -o canmount=on     zperun/root/home/share

zpool export zperun
zpool import -R /mnt zperun

findmnt # all should be mounted
mkdir /mntold
mount -o ro /dev/sda4 /mntold
rm -rf /mntold/var/lib/docker/*
rsync -axHAWXS --numeric-ids --info=progress2 /mntold /mnt
umount /mnt/old

echo '{
  "storage-driver":"zfs",
	"ipv6": true,
	"fixed-cidr-v6": "fd00::/64"
}' >> /mnt/etc/docker/daemon.json
vim /mnt/etc/docker/daemon.json

zpool set cachefile=/etc/zfs/zpool.cache zperun
cp /etc/zfs/zpool.cache /mnt/etc/zfs/zpool.cache

genfstab -U -p /mnt
genfstab -U -p /mnt >> /mnt/etc/fstab

mount /dev/sda1 /mnt/boot
arch-chroot /mnt
grub-mkconfig
ZPOOL_VDEV_NAME_PATH=1 grub-mkconfig -o /boot/grub/grub.cfg
exit

systemctl enable zfs.target --root=/mnt

umount /mnt/boot
zfs umount -a
zpool export zperun
reboot

```


