#!/bin/sh

eval `flash WLAN_WPS_CONFIGURED`

. /bin/iface-names.sh

# Restart WPS
if [ "$1" = "error" ]; then
	sleep 3
	if [ $WLAN_WPS_CONFIGURED = 0 ]; then
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfMode=7 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfStatus=1 >/dev/null 2>&1
	else
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfMode=7 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfStatus=2 >/dev/null 2>&1
	fi
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscMode=1 >/dev/null 2>&1
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscGetConf=1 >/dev/null 2>&1
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscStatus=0 >/dev/null 2>&1
	exit
fi

wps_import rt2860 /tmp/RT2860.dat

iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfMode=7 >/dev/null 2>&1
iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfStatus=2 >/dev/null 2>&1
iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscMode=1 >/dev/null 2>&1
iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscStatus=0 >/dev/null 2>&1
killall -USR1 websv 2> /dev/null
ledctl 11
