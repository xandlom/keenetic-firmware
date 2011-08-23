#!/bin/sh

. /bin/iface-names.sh

SAVE_IP="/var/udhcpc/saveip*"
CONNECTFILE=/etc/ppp/connectfile
LINKFILE=/etc/ppp/link

ppp.sh die
sleep 1
killall -9 pppd.sh 2> /dev/null
killall -1 pppd 2> /dev/null
killall -9 pppd 2> /dev/null
killall -9 ppp.sh 2> /dev/null
rm -f /var/tmp/_pppd_sh 2> /dev/null
rm -f $LINKFILE $CONNECTFILE 2> /dev/null

for interface in $BOARD_INTERFACE_WIRELESS_LAN $BOARD_INTERFACE_ETH_WAN $BOARD_INTERFACE_WIMAX_LAN; do
	PIDFILE=/etc/udhcpc/udhcpc-$interface.pid
	if [ -f $PIDFILE ] ; then
		PID=`cat $PIDFILE`
		if [ $PID != 0 ]; then
			kill -9 $PID 2> /dev/null
		fi
		rm -f $PIDFILE 2> /dev/null
	fi
done
rm -f $SAVE_IP 2> /dev/null

killall -9 igmpproxy 2> /dev/null
killall -9 miniupnpd 2> /dev/null
killall -9 wpa_supplicant 2> /dev/null
killall -9 ntp.sh 2> /dev/null
killall -9 ddns.sh 2> /dev/null
dns.sh stop
killall servtag.sh 2> /dev/null
ledctl 2

eval `flash OP_MODE`
if [ "$OP_MODE" != 'WiFi Router' ]; then
	ifconfig $BOARD_INTERFACE_WAN down 2> /dev/null
else
	ifconfig $BOARD_INTERFACE_WAN 0.0.0.0 up 2> /dev/null
fi

if [ "jingle_rmmod" = "$1" ]; then
	echo -n > /etc/resolv.conf
	COUNT=10
	while [ true ]; do
		MODULE_JING=`lsmod | grep drxvi314`
		if [ -n "$MODULE_JING" ]; then
			rmmod drxvi314 2> /dev/null
			sleep 1
			COUNT=$((COUNT-1))
			if [ $COUNT = 0 ]; then
				break
			fi
		else
			break
		fi
	done
fi

wimax-setup.sh init
