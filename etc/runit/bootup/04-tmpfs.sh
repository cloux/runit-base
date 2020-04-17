# *-*- Shell Script -*-*

#
# mount /tmp to RAM if required by /etc/default/tmpfs
#
if ! mountpoint -q /tmp; then
	# default limits. See tmpfs(5) for how to configure tmpfs size limits.
	RAMTMP=no
	TMPFS_SIZE=20%
	[ -e /etc/default/tmpfs ] && . /etc/default/tmpfs

	# RAM size must be at least 64MB
	if [ "$RAMTMP" != "no" ]; then
		MEM_TOTAL=$(grep '^MemTotal' /proc/meminfo | grep -o '[0-9]*' || printf 0)
		[ "$MEM_TOTAL" -le 65536 ] &&	RAMTMP=no
	fi

	# mount
	[ -d /tmp ] || mkdir -m0755 /tmp
	if [ "$RAMTMP" != "no" ]; then
		printf '=> Mounting /tmp to RAM ...\n'
		rm -rf /tmp/*

		# set TMP_SIZE to TMPFS_SIZE if unset
		TMP_SIZE=${TMP_SIZE:-$TMPFS_SIZE}
		# ignore SWAP space, consider only RAM size
		TMP_SIZE=${TMP_SIZE%VM}

		mount -o mode=1777,nodev,nosuid,size=${TMP_SIZE} -n -t tmpfs tmp /tmp
	fi
fi
