#!/bin/sh

eval `flash TRAP_GATE_IP`

if [ "$1" = "up" ]; then
	echo -n > /var/eztune
	ifconfig br0:1 ${TRAP_GATE_IP}1 netmask 255.255.255.255 up
else
	if [ -f /var/eztune ]; then
		rm -f /var/eztune
		ifconfig br0:1 down
	fi
fi
