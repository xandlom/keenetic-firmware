#!/bin/sh

. /bin/iface-names.sh

if [ -n "$3" ]; then
	ifconfig $1 $2 netmask $3 2> /dev/null
else
	ifconfig $1 $2 2> /dev/null
fi

while route del default dev $1 2> /dev/null
do :
done

if [ -n "$4" ]; then
	if [ "$4" != "0.0.0.0" ]; then
		route add default gw $4 dev $1 2> /dev/null
	fi
fi

if [ "$1" = "$BOARD_INTERFACE_WAN" ]; then
	killall ddns.sh
	ddns.sh
fi
