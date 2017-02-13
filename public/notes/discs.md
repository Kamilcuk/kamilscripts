# discs

http://blog.asiantuntijakaveri.fi/2012/07/restoring-full-capacity-of-sata-disk-on.html  

## HPA - Host Protected Area

https://en.wikipedia.org/wiki/Host_protected_area  
http://superuser.com/questions/642637/harddrive-wipe-out-hidden-areas-like-hpa-and-dco-also-after-malware-infectio  
https://www.utica.edu/academic/institutes/ecii/publications/articles/EFE36584-D13F-2962-67BEB146864A2671.pdf  

```
[root@Hercules ~]# hdparm -N /dev/sd{a,b}

/dev/sda:
 max sectors   = 312581808/312581808, HPA is disabled

/dev/sdb:
 max sectors   = 312579695/312581808, HPA is enabled
```

Dlatego jeden dysk jest mniejszy !! XD

```
[root@Hercules ~]# fdisk -l /dev/sd{a,b}
Disk /dev/sda: 149.1 GiB, 160041885696 bytes, 312581808 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x367f313d

Device     Boot Start       End   Sectors  Size Id Type
/dev/sda1          63 312576704 312576642  149G fd Linux raid autodetect


Disk /dev/sdb: 149.1 GiB, 160040803840 bytes, 312579695 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### Disable HPA

```
0 leonidas ~
# hdparm -N /dev/sda

/dev/sda:
 max sectors   = 976771055/976773168, HPA is enabled

0 leonidas ~
# hdparm -N p976773168 /dev/sda

/dev/sda:
 setting max visible sectors to 976773168 (permanent)
 max sectors   = 976773168/976773168, HPA is disabled
0 leonidas ~
# hdparm -N /dev/sda

/dev/sda:
 max sectors   = 976773168/976773168, HPA is disabled

```

# smartctl configuration

```
# send email, short test every day at 2 AM , long test Saturdays at 3 AM
DEVICESCAN -m <mail here@ mail> -s (S/../.././02|L/../../6/03)
```

