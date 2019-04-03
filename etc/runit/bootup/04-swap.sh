# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

[ "$VIRTUALIZATION" ] && return 0

printf '=> Initializing swap ...\n'
swapon -a 2>&1

