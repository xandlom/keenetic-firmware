#!/bin/sh

. /bin/iface-names.sh

eval `flash OP_MODE PPP_TYPE MODEM_ON_DEMAND_ENABLED MODEM_IDLE_TIME`

if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
	killall -9 diald 2>/dev/null
	PPPDFILE=/var/tmp/_pppd_sh
	killall -1 pppd 2> /dev/null
	killall -9 pppd.sh 2> /dev/null
	killall -9 pppd 2> /dev/null
	rm -f $PPPDFILE 2> /dev/null
	exit 1
fi

if [ "$MODEM_ON_DEMAND_ENABLED" = "Disabled" ] || [ "$OP_MODE" != '3G Router' ]; then
	launch "/bin/pppd.sh $1&"
else
	case $1 in
	start)
		
		diald $BOARD_INTERFACE_LAN $MODEM_IDLE_TIME
		
		;;
		
	connect)
	
		diald $BOARD_INTERFACE_LAN $MODEM_IDLE_TIME 1
	
		;;

	stop|die|disconnect)
		
		killall -9 diald 2>/dev/null
		launch "/bin/pppd.sh $1&"
		
		;;

	*)
		;;
	esac
fi
