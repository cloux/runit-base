# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

if [ -x /sbin/sysctl ] || [ -x /bin/sysctl ]; then
	msg "Loading sysctl settings:"
	for i in /run/sysctl.d/*.conf \
		/etc/sysctl.d/*.conf \
		/usr/local/lib/sysctl.d/*.conf \
		/usr/lib/sysctl.d/*.conf \
		/etc/sysctl.conf; do
		if [ -e "$i" ]; then
			printf "   %s\n" "$i"
			sysctl -p "$i" 2>&1 | sed 's/^/    \* /'
		fi
	done
fi
