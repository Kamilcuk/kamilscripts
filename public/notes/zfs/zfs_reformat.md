```
zpool create \
	-o ashift=9 \
	-o feature@async_destroy=enabled \
	-o feature@empty_bpobj=enabled \
	-o feature@lz4_compress=enabled \
	-o feature@spacemap_histogram=enabled \
	-o feature@dedup=off
	-o feature@enabled_txg=enabled \
	leoroot mirror $d /tmp/missing

