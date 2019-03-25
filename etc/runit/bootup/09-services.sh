# *-*- Shell Script -*-*
#
# Enable/disable additional services in stage 2

msg "Service activation:"

# NFS support
printf "   NFS client: "
if [ -x "$(command -v rpcbind)" ]; then
	printf "ACTIVATE ..."
	RET=$(svactivate rpcbind 2>&1)
else
	printf "deactivate ..."
	RET=$(svdeactivate rpcbind rpc.gssd rpc.statd 2>&1)
fi
if [ $? -eq 0 ]; then
	msg_ok
else
	printf "%s\n" "$RET"
fi
printf "   NFS server: "
if [ -x "$(command -v rpc.mountd)" ] && [ -x "$(command -v exportfs)" ]; then
	printf "ACTIVATE ..."
	RET=$(svactivate rpc.mountd 2>&1)
else
	printf "deactivate ..."
	RET=$(svdeactivate rpc.mountd rpc.idmapd rpc.nfsd rpc.svcgssd 2>&1)
fi
if [ $? -eq 0 ]; then
	msg_ok
else
	printf " %s\n" "$RET"
fi

# irqbalance - distribute hardware interrupts across processors
# Enable this service only in multi-CPU environment, it would
# fail to run on a single-CPU anyway.
if [ "$(command -v irqbalance)" ] && [ -d /etc/sv/irqbalance ]; then
	#CPU_COUNT=$(grep -c '^processor' /proc/cpuinfo)
	CPU_COUNT=$(nproc --all 2>/dev/null)
	printf "   irqbalance: %s CPUs: " "$CPU_COUNT"
	if [ $CPU_COUNT -gt 1 ]; then
		printf "ACTIVATE ..."
		RET=$(svactivate irqbalance 2>&1)
	else
		printf "deactivate ..."
		RET=$(svdeactivate irqbalance 2>&1)
	fi
	if [ $? -eq 0 ]; then
		msg_ok
	else
		printf " %s\n" "$RET"
	fi
fi

