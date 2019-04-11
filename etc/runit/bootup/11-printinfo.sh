# *-*- Shell Script -*-*
# Print additional system info to the console
#
# NOTE: this is run in series during boot. Slow
# commands (e.g. network checks) will cost you boot time!
#
# (cloux@rote.ch)

printf '=> System info:\n'
printf '   Time: %s\n' "$(date --iso-8601=seconds)"
printf '   CPU: %s\n' "$(grep -i 'model name' /proc/cpuinfo | head -n 1 | sed 's/[^:]*:\s*//') ($(nproc --all) Cores)"
printf '   RAM: %s GB\n' "$(($(grep '^MemTotal' /proc/meminfo | grep -o '[0-9]*')/1000000))"

LOCAL_IP="$(hostname -I 2>/dev/null)"
if [ "$LOCAL_IP" ]; then
	printf '   LAN IP: %s\n' "$LOCAL_IP"
#	PUBLIC_IP="$(/usr/local/bin/public-ip 2>/dev/null)"
#	[ "$PUBLIC_IP" ] && printf '   WAN IP: %s\n' "$PUBLIC_IP"
fi
