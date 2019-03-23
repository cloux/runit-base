# *-*- Shell Script -*-*
#
# Enable/disable additional services in stage 2

msg "Service activation:"

# NFS support
printf "   NFS client: "
if [ -x "$(command -v rpcbind)" ]; then
	printf "activate rpcbind ... "
	RET=$(svactivate rpcbind 2>&1)
else
	printf "deactivate rpcbind ... "
	RET=$(svdeactivate rpcbind rpc.gssd rpc.statd >/dev/null 2>&1)
fi
if [ $? -eq 0 ]; then
	msg_ok
else
	printf "%s\n" "$RET"
fi
printf "   NFS server: "
if [ -x "$(command -v rpc.mountd)" ] && [ -x "$(command -v exportfs)" ]; then
	printf "activate rpc.mountd ... "
	RET=$(svactivate rpc.mountd 2>&1)
else
	printf "deactivate rpc.mountd ... "
	RET=$(svdeactivate rpc.mountd rpc.idmapd rpc.nfsd rpc.svcgssd >/dev/null 2>&1)
fi
if [ $? -eq 0 ]; then
	msg_ok
else
	printf "%s\n" "$RET"
fi

# irqbalance - distribute hardware interrupts across processors
# Enable this service only in multi-CPU environment, it would
# fail to run on a single-CPU anyway.
if [ "$(command -v irqbalance)" ] && [ -d /etc/sv/irqbalance ]; then
	#CPU_COUNT=$(grep -c '^processor' /proc/cpuinfo)
	CPU_COUNT=$(nproc --all 2>/dev/null)
	printf "   CPUs detected: %s, " "$CPU_COUNT"
	if [ $CPU_COUNT -gt 1 ]; then
		printf "activate irqbalance ... "
		RET=$(svactivate irqbalance 2>&1)
	else
		printf "deactivate irqbalance ... "
		RET=$(svdeactivate irqbalance >/dev/null 2>&1)
	fi
	if [ $? -eq 0 ]; then
		msg_ok
	else
		printf "%s\n" "$RET"
	fi
fi

# VirtualBox support
# NOTE: VirtualBox autorun script could be left permanently enabled,
# it would just generate empty /var/log/autorun-virtualbox.log
if [ -x /etc/init.d/vboxdrv ]; then
	VBOX=host
elif [ -x /etc/init.d/vboxadd ]; then
	VBOX=guest
fi
if [ "$VBOX" ] && [ -f /etc/runit/autorun/virtualbox ] && \
   [ ! -x /etc/runit/autorun/virtualbox ]; then
	printf "   VirtualBox %s detected, activating support ...\n" "$VBOX"
	chmod 755 /etc/runit/autorun/virtualbox
elif [ -z "$VBOX" ] && [ -x /etc/runit/autorun/virtualbox ]; then
	printf "   VirtualBox not found, deactivating support ...\n" "$VBOX"
	chmod 644 /etc/runit/autorun/virtualbox
fi
