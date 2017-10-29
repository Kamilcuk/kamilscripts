zpool create
============


```
zpool create \
	-o ashift=9 \
	-o feature@async_destroy=enabled \
	-o feature@empty_bpobj=enabled \
	-o feature@lz4_compress=enabled \
	-o feature@multi_vdev_crash_dump=disabled \
	-o feature@spacemap_histogram=enabled \
	-o feature@enabled_txg=enabled \
	-o feature@bookmarks=disabled \
	-o feature@filesystem_limits=disabled \
	-o feature@large_blocks=enabled \
	-o feature@dedup=off \
	leoroot mirror $d /tmp/missing

```
