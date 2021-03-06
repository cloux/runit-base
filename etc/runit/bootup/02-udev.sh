# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

[ "$VIRTUALIZATION" ] && return 0

if [ -x /sbin/udevd ] || [ -x /bin/udevd ]; then
	_udevd=udevd
elif [ -x /usr/lib/systemd/systemd-udevd ]; then
	_udevd=/usr/lib/systemd/systemd-udevd
else
	printf 'WARNING: cannot find udevd!\n'
fi

if [ "${_udevd}" ]; then
	printf '=> Starting udev ...\n'
	${_udevd} --daemon
	udevadm trigger --action=add --type=subsystems
	udevadm trigger --action=add --type=devices
	# NOTE: Settle might wait very long (>30sec) for crng,
	#       this random number generator initialization takes ages,
	#       see: dmesg | grep 'random: crng init done'
	#       There is no need to block the system until udev finishes,
	#       if a service needs a specific device, that service should wait.
	#printf '=> Waiting for devices to settle ...\n'
	#udevadm settle --timeout=1
fi
