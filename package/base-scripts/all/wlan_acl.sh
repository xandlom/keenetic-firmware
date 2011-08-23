#!/bin/sh

. /bin/iface-names.sh

eval `flash OP_MODE WLAN_MAC_ACL_MODE`

if [ "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = 'Wireless Bridge' ]; then
	exit 0
fi

case "$WLAN_MAC_ACL_MODE" in
'Disabled')
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set AccessPolicy=0
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set ACLClearAll=1
	exit 0
	;;
'Black list')
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set AccessPolicy=2
	;;
'White list')
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set AccessPolicy=1
	;;
esac

iwpriv $BOARD_INTERFACE_WIRELESS_LAN set ACLClearAll=1

flash WLAN_MAC_ACL_TBL | while read line; do
	eval $line
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set ACLAddEntry=$mac
done
