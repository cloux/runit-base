# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

[ "$VIRTUALIZATION" ] && return 0

if [ -x /sbin/dmraid ] || [ -x /bin/dmraid ]; then
	printf '=> Activating dmraid devices ...\n'
	dmraid -i -ay 2>&1
fi

if [ -x /bin/btrfs ]; then
	printf '=> Activating btrfs devices ...\n'
	btrfs device scan 2>&1
fi

if [ -x /sbin/vgchange ] || [ -x /bin/vgchange ]; then
	printf '=> Activating LVM devices ...\n'
	vgchange --sysinit -a ay 2>&1
fi

if [ -e /etc/zfs/zpool.cache ] && [ -x /usr/bin/zfs ]; then
	printf '=> Activating ZFS devices ...\n'
	zpool import -c /etc/zfs/zpool.cache -N -a

	printf '=> Mounting ZFS file systems ...\n'
	zfs mount -a

	printf '=> Sharing ZFS file systems ...\n'
	zfs share -a

	# NOTE(dh): ZFS has ZVOLs, block devices on top of storage pools.
	# In theory, it would be possible to use these as devices in
	# dmraid, btrfs, LVM and so on. In practice it's unlikely that
	# anybody is doing that, so we aren't supporting it for now.
fi

# link rootfs to /dev/root
if [ ! -e /dev/root ]; then
	ROOTDEVICE="$(findmnt --noheadings --output SOURCE /)"
	printf '=> Linking %s to /dev/root ...\n' "$ROOTDEVICE"
	ln -s "$ROOTDEVICE" /dev/root
fi

# Filesystem check
([ -f /fastboot ] || grep -q fastboot /proc/cmdline) && FASTBOOT=1
([ -f /forcefsck ] || grep -q forcefsck /proc/cmdline) && FORCEFSCK="-f"
MOUNT_RW=$(mount | grep -m 1 -c ' / .*[(\s,]rw[\s,)]')
if [ -z "$FASTBOOT" ]; then
	if [ $MOUNT_RW -eq 1 ]; then
		printf '=> Remounting root read-only ...\n'
		mount -o remount,ro / 2>&1
		MOUNT_RW=0
	fi
	if [ "$FORCEFSCK" ]; then
		printf '=> Force checking rootfs:\n'
	else
		printf '=> Checking rootfs:\n'
	fi
	fsck -T / -- -p $FORCEFSCK
	printf '=> Checking non-root filesystems:\n'
	fsck -ART -t noopts=_netdev -- -p $FORCEFSCK
fi
# zero the root drive for base image distribution
if [ -f /zerofree ] || grep -q zerofree /proc/cmdline; then
	if [ -x "$(command -v zerofree)" ]; then
		printf '=> Zero free blocks on /dev/root ...\n'
		if [ $MOUNT_RW -eq 1 ]; then
			printf '=> Remounting root read-only ...\n'
			mount -o remount,ro / 2>&1 && MOUNT_RW=0
		fi
		if zerofree -v /dev/root; then
			mount -o remount,rw / && rm -f /zerofree && mount -o remount,ro
			printf '=> Finished. You can shutdown, or wait 60 sec to continue boot...\n'
			sleep 60
		fi
	else
		printf '=> Zero FAILED: zerofree command not found\n'
	fi
fi
if [ $MOUNT_RW -eq 0 ]; then
	printf '=> Mounting rootfs read-write ...\n'
	mount -o remount,rw / 2>&1
fi

printf '=> Mounting all non-network filesystems ...\n'
mount -a -t "nosysfs,nonfs,nonfs4,nosmbfs,nocifs" -O no_netdev
