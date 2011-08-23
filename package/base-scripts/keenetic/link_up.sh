#!/bin/sh

eval `flash OP_MODE PPP_TYPE DEVICE_NAME HOST_NAME \
LAN_DHCP_MODE LAN_IP_ADDR LAN_SUBNET_MASK LAN_DEFAULT_GATEWAY \
WAN_IP_ADDRESS_MODE WAN_IP_ADDR WAN_SUBNET_MASK WAN_DEFAULT_GATEWAY \
WAN_DOT1X_ENABLED WAN_MAC_ADDR`

start_wan_services() {

	dns.sh

	if [ "$WAN_DOT1X_ENABLED" = 'Enabled' ]; then
		8021x.sh
	fi

	if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
		PPP_TYPE='None'
	fi

	if [ "$OP_MODE" = '3G Router' ]; then
		ppp.sh start
	elif [ "$WAN_IP_ADDRESS_MODE" = 'Static' ]; then
		fixedip.sh $BOARD_INTERFACE_WAN $WAN_IP_ADDR $WAN_SUBNET_MASK $WAN_DEFAULT_GATEWAY
		if [ "$PPP_TYPE" != 'None' ]; then
			ppp.sh start
		else
			ledctl 1
		fi
	elif [ "$WAN_IP_ADDRESS_MODE" = 'Auto' ]; then
		dhcpc.sh $BOARD_INTERFACE_WAN &
	elif [ "$WAN_IP_ADDRESS_MODE" = 'No IP' ]; then
		if [ "$PPP_TYPE" = 'PPPoE' ]; then
			ppp.sh start
		fi
	fi	

	killall firewall.sh 2> /dev/null
	firewall.sh

	killall ntp.sh 2> /dev/null
	ntp.sh
	killall ddns.sh 2> /dev/null
	ddns.sh
	killall servtag.sh 2> /dev/null
	servtag.sh

	route.sh
	igmpproxy.sh
}

start_wide_services() {
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = '3G Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
		upnp.sh
	fi
}

. /bin/iface-names.sh

WAN_STATUS=/var/tmp/wan_iface
echo "down" > $WAN_STATUS
link_down.sh

ifconfig $BOARD_INTERFACE_WAN up 2> /dev/null

if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = '3G Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
	start_wan_services
	# fix for restart pppd
	rm -f /var/tmp/ppp_kill 2> /dev/null
fi

start_wide_services

zyut udpreset &

INIT=/media/DISK_A1/system/bin/ext_init.sh

if [ -x $INIT ]; then
        $INIT link_up 2> /dev/null
fi

rm -f $WAN_STATUS
