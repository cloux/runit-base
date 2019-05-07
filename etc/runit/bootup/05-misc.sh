# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

if [ -f /sys/devices/system/cpu/microcode/reload ]; then
	printf '=> Loading CPU microcode ...\n'
	printf '1' > /sys/devices/system/cpu/microcode/reload
fi

if [ -f /var/lib/random-seed ]; then
	printf '=> Initializing random seed ...\n'
	cp /var/lib/random-seed /dev/urandom >/dev/null 2>&1 || true
	( umask 077; bytes=$(cat /proc/sys/kernel/random/poolsize) || bytes=512; \
		dd if=/dev/urandom of=/var/lib/random-seed count=1 bs=$bytes >/dev/null 2>&1 )
else
	touch /var/lib/random-seed
fi

if [ "$(command -v update-binfmts)" ]; then
	printf '=> Enabling executable binary formats ...\n'
	update-binfmts --enable
fi

printf '=> Setting up loopback interface ...\n'
ip link set up dev lo

[ -r /etc/hostname ] && read -r HOSTNAME < /etc/hostname
if [ -n "$HOSTNAME" ]; then
	printf '=> Setting hostname to %s ...\n' "$HOSTNAME"
	printf '%s' "$HOSTNAME" > /proc/sys/kernel/hostname
else
	printf 'WARNING: Didn'\''t setup a hostname!\n'
fi

if [ -n "$TIMEZONE" ]; then
	printf '=> Setting up timezone to %s ...\n' "$TIMEZONE"
	ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
fi
