#!/bin/sh

. /bin/iface-names.sh

WAN=$BOARD_INTERFACE_WAN
LAN=$BOARD_INTERFACE_LAN
IPTABLES=iptables
PIDFILE=/var/run/miniupnpd.pid
UPNPLEASE=/var/miniupnpd.lease

eval `flash UPNP_ENABLED PPP_TYPE OP_MODE WAN_IP_ADDRESS_MODE`

if [ ! -f $UPNPLEASE ]; then
	echo -n > $UPNPLEASE
fi

killall -15 miniupnpd 2> /dev/null

if [ -f $PIDFILE ]; then
	# PID=`cat $PIDFILE`
	# kill -9 $PID 2> /dev/null
	rm -f $PIDFILE
fi

LAN_IP=`ifconfig $LAN 2> /dev/null | grep "inet addr" | cut -f1 -d"B"| cut -f2 -d":"`
if [ "$LAN_IP" = "" ]; then
	exit
fi

route del -net 239.0.0.0 netmask 255.0.0.0 $LAN 2> /dev/null
route add -net 239.0.0.0 netmask 255.0.0.0 $LAN 2> /dev/null

$IPTABLES -t nat -F MINIUPNPD 2> /dev/null
$IPTABLES -t filter -F MINIUPNPD 2> /dev/null
$IPTABLES -t nat -N MINIUPNPD 2> /dev/null
$IPTABLES -t filter -N MINIUPNPD 2> /dev/null

if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
	PPP_TYPE='None'
fi

if [ "$UPNP_ENABLED" = 'Enabled' ]; then
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
		$IPTABLES -t nat -D PREROUTING -i $WAN -j MINIUPNPD 2> /dev/null
		$IPTABLES -t filter -D FORWARD -i $WAN -o ! $WAN -j MINIUPNPD 2> /dev/null
		if [ "$WAN_IP_ADDRESS_MODE" != 'No IP' ]; then
			$IPTABLES -t nat -A PREROUTING -i $WAN -j MINIUPNPD 2> /dev/null
			$IPTABLES -t filter -A FORWARD -i $WAN -o ! $WAN -j MINIUPNPD 2> /dev/null
		fi
	fi

	if [ "$PPP_TYPE" != 'None' -o "$OP_MODE" = '3G Router' ]; then
		WAN=ppp0
		$IPTABLES -t nat -D PREROUTING -i $WAN -j MINIUPNPD 2> /dev/null
		$IPTABLES -t filter -D FORWARD -i $WAN -o ! $WAN -j MINIUPNPD 2> /dev/null
		$IPTABLES -t nat -A PREROUTING -i $WAN -j MINIUPNPD 2> /dev/null
		$IPTABLES -t filter -A FORWARD -i $WAN -o ! $WAN -j MINIUPNPD 2> /dev/null
	fi

	miniupnpd -a $LAN_IP -i $WAN
else
	$IPTABLES -t nat -X MINIUPNPD 2> /dev/null
	$IPTABLES -t filter -X MINIUPNPD 2> /dev/null
	echo -n > $UPNPLEASE
fi
