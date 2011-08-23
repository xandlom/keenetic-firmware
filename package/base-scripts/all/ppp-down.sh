#!/bin/sh

LINKFILE=/etc/ppp/link
CONNECTFILE=/etc/ppp/connectfile
INIT=/media/DISK_A1/system/bin/ext_init.sh

eval `flash PPP_TYPE`

if [ -x $INIT ]; then
	$INIT ppp_down $1 $2 $3 $4 $5 $6 2> /dev/null
fi

[ -r "$CONNECTFILE" ] && rm $CONNECTFILE
[ -r "$LINKFILE" ] && rm $LINKFILE

if [ -n "$USEPEERDNS" -a -f /etc/ppp/resolv.conf ]; then
	if [ -f /etc/ppp/resolv.prev ]; then
		cp -f /etc/ppp/resolv.prev /etc/resolv.conf
	else
		echo -n > /etc/resolv.conf
	fi
fi

echo -n > /etc/ppp/resolv.conf

dns.sh
upnp.sh

if [ "$PPP_TYPE" = 'PPPoE' ]; then
	if [ -f /proc/net/hwnat_stat_uid ]; then
		echo "del,$1" > /proc/net/hwnat_stat_uid
	fi
fi

ledctl 2
