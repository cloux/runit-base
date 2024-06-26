# *-*- Shell Script -*-*
#
# Autorun
#
# Run scripts in /etc/runit/autorun/ in parallel at the end of
# the boot stage. Symlinks are not allowed, only executable files.
# These scripts should perform tasks only needed once after boot,
# they should not daemonize and will not be supervised.
#
# (jan@wespe.dev)

if ls -l /etc/runit/autorun/ 2>/dev/null | grep -q '^[rw\-]*[xs]'; then
	printf '=> Starting autorun scripts in parallel:\n'
	OUTPUT=/dev/null
	for f in /etc/runit/autorun/*; do
		if [ -h "$f" ]; then
			printf '   NOTE: %s is a symlink and should be removed\n' "$f"
			continue
		fi
		([ -f "$f" ] && [ -x "$f" ]) || continue
		printf '   %s\n' "$f"
		[ -d /var/log ] && OUTPUT=/var/log/autorun-${f##*/}.log
		nohup "$f" >"$OUTPUT" 2>&1 &
	done
fi
