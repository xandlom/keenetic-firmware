#!/bin/sh

# This script configures bridges correctly

. /bin/iface-names.sh
eval `flash OP_MODE WLAN_ENABLED WLAN_WDS_ENABLED LAN_MAC_ADDR WAN_MAC_ADDR IPTV_MODE IPTV_VLAN_TV_TAG IPTV_VLAN_TV2_TAG IPTV_VLAN_TV2_ENABLED`

echo 'Configuring network topology'

cleanup_bridges() {
	for iface in `brctl show | cut -f 5- | grep -v interfaces`; do
		ifconfig $iface down 2> /dev/null
	done
	for bridge in `brctl show | cut -f 1 | grep -v bridge`; do
		ifconfig $bridge down 2> /dev/null
		brctl delbr $bridge 2> /dev/null
	done
	if [ -n "$BOARD_INTERFACE_ETH_BASE" ]; then
		ifconfig $BOARD_INTERFACE_ETH_BASE down 2> /dev/null
	fi
}

setup_lan_bridge() {
	if [ $BOARD_INTERFACE_LAN_BRIDGE != 1 ]; then
		return;
	fi

	brctl addbr $BOARD_INTERFACE_LAN 2> /dev/null
	brctl setfd $BOARD_INTERFACE_LAN 1 2> /dev/null

	brctl addif $BOARD_INTERFACE_LAN $BOARD_INTERFACE_ETH_LAN 2> /dev/null
	ifconfig $BOARD_INTERFACE_ETH_LAN 0.0.0.0 2> /dev/null
	
	if [ "$OP_MODE" != 'WiFi Router' -a "$WLAN_ENABLED" = 'Enabled' ] ; then
		ifconfig $BOARD_INTERFACE_WIRELESS_LAN 0.0.0.0 2> /dev/null
		brctl addif $BOARD_INTERFACE_LAN $BOARD_INTERFACE_WIRELESS_LAN 2> /dev/null
		if [ "$WLAN_WDS_ENABLED" != 'Disabled' ] ; then
			ifconfig -a | grep wds | cut -d " " -f 1 | while read iface; do
				brctl addif $BOARD_INTERFACE_LAN $iface 2> /dev/null
				ifconfig $iface 0.0.0.0 2> /dev/null
			done
		fi
	fi
	if [ "$OP_MODE" != 'Ethernet Router' -a "x$BOARD_INTERFACE_BRIDGE_INCLUDE_ETH_WAN" != "x0" ]; then
		brctl addif $BOARD_INTERFACE_LAN $BOARD_INTERFACE_ETH_WAN 2> /dev/null
		ifconfig $BOARD_INTERFACE_ETH_WAN 0.0.0.0 2> /dev/null
	fi
}

setup_lan_mac() {
	HW_NIC0_ADDR="00:19:CB:0A:58:5A"

	if [ "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = 'Wireless Bridge' ]; then
		LAN_MAC_CFG=`getmac -w`
	else
		LAN_MAC_CFG=`getmac -l`
	fi
	if [ -n "$LAN_MAC_CFG" ]; then
		HW_NIC0_ADDR=$LAN_MAC_CFG
	fi
	
	if [ "$LAN_MAC_ADDR" = "00:00:00:00:00:00" ]; then
		LAN_MAC_ADDR=$HW_NIC0_ADDR
	fi
	if [ -n "$BOARD_INTERFACE_ETH_BASE" ]; then
		ifconfig $BOARD_INTERFACE_ETH_BASE hw ether $LAN_MAC_ADDR 2> /dev/null
	fi
	ifconfig $BOARD_INTERFACE_ETH_LAN hw ether $LAN_MAC_ADDR 2> /dev/null
}

setup_wan_mac() {
	HW_NIC1_ADDR="00:19:CB:0A:58:5B"

	WAN_MAC_CFG=`getmac -w`
	if [ -n "$WAN_MAC_CFG" ]; then
		HW_NIC1_ADDR=$WAN_MAC_CFG
	fi

	if [ "$OP_MODE" != 'WiFi Router' -a "$OP_MODE" != '3G Router' -a "$OP_MODE" != 'WiMAX Router' -a "$OP_MODE" != 'WiFi Access Point' ]; then
		if [ "$WAN_MAC_ADDR" = "00:00:00:00:00:00" ]; then
			WAN_MAC_ADDR=$HW_NIC1_ADDR
		fi
		ifconfig $BOARD_INTERFACE_WAN hw ether $WAN_MAC_ADDR 2> /dev/null
	fi
}

raise_wan_interfaces() {
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
		ifconfig $BOARD_INTERFACE_WAN up 2> /dev/null
		if [ -f /proc/sys/net/ipv4/conf/$BOARD_INTERFACE_WAN/arp_filter ]; then
			echo "1" > /proc/sys/net/ipv4/conf/$BOARD_INTERFACE_WAN/arp_filter
		fi
	fi
}

setup_iptv_bridge() {
    # Add multi-VLAN support
	if [ "$OP_MODE" = 'Ethernet Router' -a "$IPTV_MODE" = '802.1q' ]; then
		brctl addbr br1 2> /dev/null
		brctl setfd br1 1 2> /dev/null

		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			ifconfig $BOARD_INTERFACE_ETH_BASE.$IPTV_VLAN_TV2_TAG 0.0.0.0 2> /dev/null
			brctl addif br1 $BOARD_INTERFACE_ETH_BASE.$IPTV_VLAN_TV2_TAG 2> /dev/null
		fi
		ifconfig $BOARD_INTERFACE_ETH_BASE.$IPTV_VLAN_TV_TAG 0.0.0.0 2> /dev/null
		brctl addif br1 $BOARD_INTERFACE_ETH_BASE.$IPTV_VLAN_TV_TAG 2> /dev/null
		ifconfig br1 up 2> /dev/null		
	fi
}

cleanup_bridges

setup_lan_mac

setup-switch.sh

setup_lan_bridge

setup_wan_mac

raise_wan_interfaces

setup_iptv_bridge
