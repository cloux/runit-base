# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

# Some kernel modules must be loaded before starting udev(7).
# Load them by looking at the output of `kmod static-nodes`.

printf '=> Loading static nodes:\n'
for f in $(kmod static-nodes 2>/dev/null | awk '/Module/ {print $2}'); do
	# NOTE: skip btrfs, it slows down booting by running crypto benchmarks.
	#       if you need btrfs loaded, add it to /etc/modules
	[ "$f" = "btrfs" ] && continue
	printf '   %s ' "$f"
	modprobe -q "$f" 2>&1 && printf 'OK\n'
done
