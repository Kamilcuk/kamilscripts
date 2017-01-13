# depends on

$ pacman -Qi zfs-linux 2>/dev/null | grep Depends 
Depends On      : kmod  spl-linux  zfs-utils-linux  linux=4.8.13
$ pacman -Qi zfs-utils-linux 2>/dev/null | grep Depends 
Depends On      : spl-linux  linux=4.8.13

# list
```

list=spl-linux spl-utils-linux zfs-utils-linux zfs-linux

for i in $list; do
	cp /var/lib/pacman/local/$i-[0-9]* $dest
done

```
