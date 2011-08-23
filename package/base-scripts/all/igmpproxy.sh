#!/bin/sh

. /bin/iface-names.sh

eval `flash OP_MODE LAN_DHCP_SNOOPING_ENABLED IPTV_MODE`

IGMP_PROXY=/bin/igmpproxy
IGMP_PROXY_CFG=/var/igmpproxy.conf
IGMPSN_CFG=/var/igmpsn.cfg
IGMPSN_MODULE=igmpsn
IGMPSN=/lib/modules/2.6.23-rt/$IGMPSN_MODULE.ko
USE_IGMP_PROXY=0
OLD_OP_MODE=255

igmpproxy_conf() {
	WAN_IF=$BOARD_INTERFACE_WAN
	if [ "$OP_MODE" = 'Ethernet Router' -a "$IPTV_MODE" = '802.1q' ]; then
		WAN_IF=br1
	fi
	echo "quickleave

	phyint $WAN_IF upstream
	altnet 0.0.0.0/0

	phyint $BOARD_INTERFACE_LAN downstream" > $IGMP_PROXY_CFG
}

if [ -x $IGMP_PROXY ]; then
	killall -9 igmpproxy 2> /dev/null
	USE_IGMP_PROXY=1
elif [ -f $IGMPSN ]; then
	USE_IGMP_PROXY=2
	if [ -f $IGMPSN_CFG ]; then
		. $IGMPSN_CFG
	fi
	echo "OLD_OP_MODE=\"$OP_MODE\"" > $IGMPSN_CFG
fi

if [ $USE_IGMP_PROXY = 2 ] && [ "$OLD_OP_MODE" != "$OP_MODE" ]; then
	rmmod $IGMPSN_MODULE 2> /dev/null
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' ]; then
		# IGMP Snooping & IPTV Bridge
		WAN_IF=$BOARD_INTERFACE_WAN
		if [ "$OP_MODE" = 'Ethernet Router' -a "$IPTV_MODE" = '802.1q' ]; then
			WAN_IF=br1
		fi
		insmod $IGMPSN wan_if=$WAN_IF lan_if=$BOARD_INTERFACE_LAN 2> /dev/null
	elif [ "$OP_MODE" = 'Wireless Bridge' ]; then
		# IGMP Snooping & IPTV Bridge & WET mode & DHCP Snooping
		DSNOOP=""
		if [ "$LAN_DHCP_SNOOPING_ENABLED" = "Enabled" ]; then
			DSNOOP="dhcp_snooping=1"
		fi
		insmod $IGMPSN wan_if=$BOARD_INTERFACE_WAN lan_if=$BOARD_INTERFACE_ETH_LAN wet_if=$BOARD_INTERFACE_LAN $DSNOOP 2> /dev/null
	else
		# Only IGMP Snooping
		insmod $IGMPSN 2> /dev/null
	fi
fi

if [ $USE_IGMP_PROXY = 1 ]; then 
	if [ -f $IGMPSN ]; then
		MODULE=`lsmod | grep $IGMPSN_MODULE`
		if [ ! -n "$MODULE" ]; then
			# Only IGMP Snooping
			insmod $IGMPSN 2> /dev/null
		fi
	fi
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' ]; then
		igmpproxy_conf
		watcher /bin/igmpproxy -f &
	fi
fi

# Fix for working IPTV on WiFi in AP mode.
iwpriv $BOARD_INTERFACE_WIRELESS_LAN set IgmpSnEnable=1 >/dev/null 2>&1
