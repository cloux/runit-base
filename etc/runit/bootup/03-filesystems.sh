# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

[ "$VIRTUALIZATION" ] && return 0

if [ -x /sbin/dmraid ] || [ -x /bin/dmraid ]; then
	msg "Activating dmraid devices ..."
	dmraid -i -ay 2>&1
fi

if [ -x /bin/btrfs ]; then
	msg "Activating btrfs devices ..."
	btrfs device scan 2>&1
fi

if [ -x /sbin/vgchange ] || [ -x /bin/vgchange ]; then
	msg "Activating LVM devices ..."
	vgchange --sysinit -a ay 2>&1
fi

if [ -e /etc/zfs/zpool.cache ] && [ -x /usr/bin/zfs ]; then
	msg "Activating ZFS devices ..."
	zpool import -c /etc/zfs/zpool.cache -N -a

	msg "Mounting ZFS file systems ..."
	zfs mount -a

	msg "Sharing ZFS file systems ..."
	zfs share -a

	# NOTE(dh): ZFS has ZVOLs, block devices on top of storage pools.
	# In theory, it would be possible to use these as devices in
	# dmraid, btrfs, LVM and so on. In practice it's unlikely that
	# anybody is doing that, so we aren't supporting it for now.
fi

# link rootfs to /dev/root
if [ ! -e /dev/root ]; then
	ROOTDEVICE="$(findmnt --noheadings --output SOURCE /)"
	msg "Link $ROOTDEVICE to /dev/root ..."
	ln -s "$ROOTDEVICE" /dev/root
fi

# Filesystem check
([ -f /fastboot ] || grep -q fastboot /proc/cmdline) && FASTBOOT=1
([ -f /forcefsck ] || grep -q forcefsck /proc/cmdline) && FORCEFSCK="-f"
MOUNT_RW=$(mount | grep -m 1 -c ' / .*[(\s,]rw[\s,)]')
if [ -z "$FASTBOOT" ]; then
	if [ "$FORCEFSCK" ]; then
		if [ $MOUNT_RW -eq 1 ]; then
			msg "Remounting root read-only ..."
			mount -o remount,ro / 2>&1
			MOUNT_RW=0
		fi
		msg "Force checking rootfs:"
		fsck -T / -- -p $FORCEFSCK
	else
		# repair the filesystem only if damaged.
		# this should allow faster boot if filesystem is OK
		msg "Checking rootfs:"
		fsck -T / -- -n
		if [ $? -ne 0 ]; then
			if [ $MOUNT_RW -eq 1 ]; then
				msg "Remounting root read-only ..."
				mount -o remount,ro / 2>&1
				MOUNT_RW=0
			fi
			msg "Repairing damaged rootfs:"
			fsck -T / -- -p
		fi
	fi
	msg "Checking non-root filesystems:"
	fsck -ART -t noopts=_netdev -- -p $FORCEFSCK
fi
# zero the root drive for base image distribution
if [ -f /zerofree ] || grep -q zerofree /proc/cmdline; then
	if [ -x "$(command -v zerofree)" ]; then
		msg "Zero free blocks on /dev/root ..."
		if [ $MOUNT_RW -eq 1 ]; then
			msg "Remounting root read-only ..."
			mount -o remount,ro / 2>&1 && MOUNT_RW=0
		fi
		if zerofree /dev/root; then
			msg "Finished. You can shutdown, or wait 60 sec to continue boot..."
			mount -o remount,rw / && rm -f /zerofree
			sleep 60
		fi
	else
		msg "Zero FAILED: zerofree command not found"
	fi
fi
if [ $MOUNT_RW -eq 0 ]; then
	msg "Mounting rootfs read-write ..."
	mount -o remount,rw / 2>&1
fi

msg "Mounting all non-network filesystems ..."
mount -a -t "nosysfs,nonfs,nonfs4,nosmbfs,nocifs" -O no_netdev


