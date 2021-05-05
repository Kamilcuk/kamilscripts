
# https://www.reddit.com/r/archlinux/comments/fkcamq/noob_btrfs_subvolume_layout_help/
# https://btrfs.wiki.kernel.org/index.php/SysadminGuide
# https://bbs.archlinux.org/viewtopic.php?id=194491
# https://wiki.archlinux.org/title/Snapper#Automatic_timeline_snapshots
# https://man.archlinux.org/man/snapper-configs.5

---

fdisk /dev/sda -> /dev/sda3 type Linux
mkfs.btrfs -L bperun /dev/sda3
mount /dev/sda3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@homeroot
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@worker
btrfs subvolume create /mnt/@share
btrfs subvolume create /mnt/@docker

cat <<EOF >> /etc/fstab
LABEL=bperun /               btrfs defaults,noatime,compress=zstd,subvol=@         0 0
LABEL=bperun /root           btrfs defaults,noatime,compress=zstd,subvol=@homeroot 0 0
LABEL=bperun /home           btrfs defaults,noatime,compress=zstd,subvol=@home     0 0
LABEL=bperun /home/worker    btrfs defaults,noatime,compress=zstd,subvol=@worker   0 0
LABEL=bperun /share          btrfs defaults,noatime,compress=zstd,subvol=@share    0 0
LABEL=bperun /var/lib/docker btrfs defaults,noatime,compress=zstd,subvol=@docker   0 0
EOF

GRUB_PRELOAD_MODULES="btrfs" to /etc/default/grub

mount /dev/sda1 /mnt/boot

grub-mkconfig -o /boot/grub/grub.cfg

# Cleanup zfs

- uninstall zfs
- remove zfs from /etc/mkinitcpio.conf
- regenerate linux kernel
- remove zfs from grub if any
- remove zfs from /etc/fstab
- referenerate /etc/fstab


