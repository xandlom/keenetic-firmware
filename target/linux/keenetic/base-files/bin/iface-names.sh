#!/bin/sh

eval `flash get DEBUG`
if [ "$DEBUG" = "Enabled" ]; then
	set -x
fi

# Interface names

BOARD_INTERFACE_ETH_WAN=eth2.2
BOARD_INTERFACE_ETH_LAN=eth2.1
BOARD_INTERFACE_WIRELESS_LAN=ra0
BOARD_INTERFACE_WIMAX_LAN=wimax0
BOARD_INTERFACE_LAN=br0

# Fixes IPTV streaming case

eval `flash get IPTV_MODE OP_MODE`

if [ "$OP_MODE" = 'Ethernet Router' -a "$IPTV_MODE" = '802.1q' ]; then 
	eval `flash get IPTV_VLAN_WAN_TAG`
	BOARD_INTERFACE_ETH_WAN=eth2.$IPTV_VLAN_WAN_TAG
fi

# To find out the name of the WAN

if [ "$OP_MODE" = 'WiFi Router' ] || [ "$OP_MODE" = 'Wireless Bridge' ]; then
	BOARD_INTERFACE_WAN=$BOARD_INTERFACE_WIRELESS_LAN
elif [ "$OP_MODE" = 'WiMAX Router' ]; then
	BOARD_INTERFACE_WAN=$BOARD_INTERFACE_WIMAX_LAN
else
	BOARD_INTERFACE_WAN=$BOARD_INTERFACE_ETH_WAN
fi

# Get board configuration

BOARD_INTERFACE_LAN_BRIDGE=1
BOARD_INTERFACE_BRIDGE_INCLUDE_ETH_WAN=0
BOARD_INTERFACE_ETH_BASE=eth2
