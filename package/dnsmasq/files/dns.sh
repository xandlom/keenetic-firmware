#!/bin/sh

# This script creates proper resolv.conf and starts dnsmasq daemon as DNS proxy

RESOLV=/etc/resolv.conf
UDHCP_RESOLV=/var/udhcpc/resolv.conf
PPP_RESOLV=/etc/ppp/resolv.conf
PID_FILE=/var/run/dnsmasq.pid

if [ "$1" != "start" ]; then
	killall -9 dnsmasq 2> /dev/null
	rm -f $PID_FILE 2> /dev/null
fi

[ "$1" = "stop" ] && \
	exit 0

eval `flash WAN_DNS_MODE WAN_IP_ADDRESS_MODE WAN_DNS1 WAN_DNS2 WAN_DNS3 OP_MODE TRAP_GATE_IP`

echo -n > $RESOLV
if [ "$WAN_DNS_MODE" = 'Enabled' -a "$WAN_IP_ADDRESS_MODE" = 'Auto' ]; then
	if [ -f $UDHCP_RESOLV ]; then
		cat $UDHCP_RESOLV >> $RESOLV
	fi
	if [ -f $PPP_RESOLV ]; then
		cat $PPP_RESOLV >> $RESOLV
	fi
else
	if [ -f $PPP_RESOLV ]; then
		cat $PPP_RESOLV >> $RESOLV
	fi
	if [ "$WAN_DNS1" != '0.0.0.0' ]; then 
		echo "nameserver $WAN_DNS1" >> $RESOLV 
	fi 
	if [ "$WAN_DNS2" != '0.0.0.0' ]; then 
		echo "nameserver $WAN_DNS2" >> $RESOLV 
	fi 
	if [ "$WAN_DNS3" != '0.0.0.0' ]; then 
		echo "nameserver $WAN_DNS3" >> $RESOLV 
	fi 
fi

dnsmasq -u root -f --all-servers -k &
