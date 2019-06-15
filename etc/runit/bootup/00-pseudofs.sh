# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

printf '=> Mounting pseudo-filesystems ...\n'
mountpoint -q /proc || mount -o nosuid,noexec,nodev -t proc proc /proc
mountpoint -q /proc/sys/fs/binfmt_misc || ( [ -d /proc/sys/fs/binfmt_misc ] && \
              mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc )
mountpoint -q /sys || mount -o nosuid,noexec,nodev -t sysfs sys /sys
mountpoint -q /sys/fs/pstore || mount -o nosuid,noexec,nodev -t pstore pstore /sys/fs/pstore
mountpoint -q /sys/kernel/config || mount -t configfs configfs /sys/kernel/config 2>/dev/null
mountpoint -q /sys/kernel/security || mount -t securityfs securityfs /sys/kernel/security 2>/dev/null
mountpoint -q /dev || mount -o mode=0755,nosuid -t devtmpfs dev /dev
mkdir -p -m0755 /dev/pts
mountpoint -q /dev/pts || mount -o mode=0620,gid=5,nosuid,noexec -n -t devpts devpts /dev/pts
mkdir -p -m0755 /dev/mqueue
mountpoint -q /dev/mqueue || mount -t mqueue mqueue /dev/mqueue 2>/dev/null
mountpoint -q /run || mount -o mode=0755,nosuid,nodev -t tmpfs run /run
mkdir -p -m0755 /run/shm /run/lvm /run/user /run/lock /run/log /run/rpc_pipefs
mountpoint -q /run/shm || mount -o mode=1777,nosuid,nodev -n -t tmpfs shm /run/shm
mountpoint -q /run/rpc_pipefs || mount -o nosuid,noexec,nodev -t rpc_pipefs rpc_pipefs /run/rpc_pipefs

# compatibility symlink
ln -sf /run/shm /dev/shm

# Detect LXC virtualization containers
grep -q lxc /proc/self/environ >/dev/null && export VIRTUALIZATION=1

if [ -z "$VIRTUALIZATION" ]; then
	if ! mountpoint -q /sys/fs/cgroup; then
		mkdir -p -m0755 /sys/fs/cgroup
		# try to mount cgroup2 single hierarchy, fallback to cgroup v1
		mount -t cgroup2 cgroup2 /sys/fs/cgroup || mount -o mode=0755 -t tmpfs cgroup /sys/fs/cgroup
		# add cgroup v1 hierarchy
		for cg in $(grep '1$' /proc/cgroups 2>/dev/null | cut -f 1); do
			mkdir /sys/fs/cgroup/$cg && mount -t cgroup -o $cg cgroup /sys/fs/cgroup/$cg
		done
	fi
fi
