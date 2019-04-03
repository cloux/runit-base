# *-*- Shell Script -*-*
# from VOID Linux (https://www.voidlinux.org)

[ "$VIRTUALIZATION" ] && return 0

TTYS=${TTYS:-12}
if [ -n "$FONT" ]; then
	printf '=> Setting up TTYs font to %s ...\n' "$FONT"
	_index=0
	while [ ${_index} -le $TTYS ]; do
		setfont ${FONT_MAP:+-m $FONT_MAP} ${FONT_UNIMAP:+-u $FONT_UNIMAP} "$FONT" -C "/dev/tty${_index}"
		_index=$((_index + 1))
	done
fi

if [ "$KEYMAP" ]; then
	printf '=> Setting up keymap to %s ...\n' "$KEYMAP"
	loadkeys -q -u "$KEYMAP"
fi

if [ -n "$HARDWARECLOCK" ]; then
	printf '=> Setting up RTC to %s ...\n' "$HARDWARECLOCK"
	TZ=$TIMEZONE hwclock --systz ${HARDWARECLOCK:+--$(echo "$HARDWARECLOCK" | tr '[:upper:]' '[:lower:]') --noadjfile} || true
fi
