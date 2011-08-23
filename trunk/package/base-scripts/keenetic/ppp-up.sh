#!/bin/sh

killall firewall.sh 2> /dev/null
firewall.sh

CONNECTFILE=/etc/ppp/connectfile
LINKFILE=/etc/ppp/link

eval `flash LAN_IP_ADDR PPP_TYPE`

if [ "$LAN_IP_ADDR" = "$4" ]; then
	killall -1 pppd 2> /dev/null
	exit
fi

echo "pass" > $CONNECTFILE
cp /proc/uptime $LINKFILE
# igmpproxy.sh

if [ -n "$USEPEERDNS" -a -f /etc/ppp/resolv.conf ]; then
	CHECK_DNS=`cat /etc/ppp/resolv.conf | grep 10.11.12.1[3,4] | wc -l`
	if [ $CHECK_DNS = 2 ]; then
		echo "nameserver 8.8.8.8" > /etc/ppp/resolv.conf
		echo "nameserver 8.8.4.4" >> /etc/ppp/resolv.conf
	fi
	if [ ! -f /etc/resolv.conf ]; then
		cp /etc/ppp/resolv.conf /etc
	fi
fi

if [ "$PPP_TYPE" = 'PPPoE' ]; then
	if [ -f /proc/net/hwnat_stat_uid ]; then
		echo "add,$1,0,$7" > /proc/net/hwnat_stat_uid
	fi
fi

eztune.sh down
dns.sh

killall ddns.sh 2> /dev/null
ddns.sh

upnp.sh

zyut udpreset &
# fix get time on ppp...
killall -1 ntpclient 2> /dev/null

INIT=/media/DISK_A1/system/bin/ext_init.sh

if [ -x $INIT ]; then
        $INIT ppp_up $1 $2 $3 $4 $5 $6 2> /dev/null
fi

ledctl 1

