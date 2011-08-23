#!/bin/sh

MODEM=""
CHK_RUN=""
MODEM_STATUS=/var/usbstatus/modem
PRINTER_STATUS=/var/usbstatus/printer
STORAGE_STATUS=/var/usbstatus/storage
WIMAX_STATUS=/var/usbstatus/wimax
WIMAX_FWVER=/var/usbstatus/wimax_fwver
WIMAX_CONNECT_STATUS=/var/usbstatus/wimax_connect_status
WIMAX_LOCK=/var/wimax.lock
WIMAX_LINKFILE=/var/tmp/wimax.link
UMOD_SAMS=/lib/modules/2.6.23-rt/u200.ko
UMOD_JING=/lib/modules/2.6.23-rt/drxvi314.ko
LINKMOD=/lib/modules/2.6.23-rt/wilink.ko
YOTA_READY=/bin/yota_ready.sh
PROC_USB=/proc/bus/usb/devices
JINGLE_LINK_STATUS=/var/tmp/jingle_status
JINGLE_FWVER=/var/tmp/jingle_fwver
KEY_LINK_STATUS=/var/tmp/key_status
KEY_FWVER=/var/tmp/key_fwver

if [ ! -f $JINGLE_LINK_STATUS ] && [ ! -f $KEY_LINK_STATUS ]; then
	echo 0 > $WIMAX_CONNECT_STATUS
	rm -f $WIMAX_LINKFILE
fi
. /bin/iface-names.sh

if [ -f $WIMAX_LOCK ] || [ ! -f $PROC_USB ]; then
	exit
fi

eval `flash OP_MODE WLAN_STA_MONITORING_ENABLED`

usb_device() {
	if [ -f $PRINTER_STATUS ] || [ -f $MODEM_STATUS ] || [ -f $STORAGE_STATUS ] || [ -f $WIMAX_STATUS ]; then
		ledctl 12
	else
		ledctl 13
	fi
}

mkdir -p /var/usbstatus 2> /dev/null
rm -f $WIMAX_STATUS 2> /dev/null

grep -q 'Vendor=1076 ProdID=7708' $PROC_USB && MODEM="Yota One"
grep -q 'Vendor=0525 ProdID=a4a2' $PROC_USB && MODEM="Yota One"
grep -q 'Vendor=198f ProdID=0220' $PROC_USB && MODEM="Yota Jingle WU217"
grep -q 'Vendor=04e9 ProdID=6761' $PROC_USB && MODEM="Samsung SWC-U200"
grep -q 'Vendor=04e8 ProdID=6761' $PROC_USB && MODEM="Samsung SWC-U200"
grep -q 'Vendor=04e8 ProdID=6731' $PROC_USB && MODEM="Samsung SWC-U200"
grep -q 'Vendor=04e8 ProdID=6780' $PROC_USB && MODEM="Samsung SWC-U200"

if [ "$OP_MODE" != 'WiMAX Router' ]; then
	rmmod u200 2> /dev/null
	rmmod drxvi314 2> /dev/null
	if [ "$OP_MODE" != 'WiFi Router' ]; then
		rmmod wilink 2> /dev/null
	elif [ "$OP_MODE" = 'WiFi Router' -a "$WLAN_STA_MONITORING_ENABLED" != 'Enabled' ]; then
		rmmod wilink 2> /dev/null
	fi
	usb_device
	if [ -n "$MODEM" ]; then
		flash set OP_MODE 'WiMAX Router'
		# init.sh
		reboot
	fi
	exit
fi

MODULE_JING=`lsmod | grep drxvi314`
MODULE_SAMS=`lsmod | grep u200`

echo "start" > $WIMAX_LOCK

wimax_down() {
	rm -f $WIMAX_STATUS 2> /dev/null
	echo -n > /etc/resolv.conf
	usb_device
	if [ -x $YOTA_READY ]; then
		$YOTA_READY stop
	fi
	/bin/link_down.sh
	dns.sh stop
	echo -n > /etc/resolv.conf
	if [ -n "$MODULE_SAMS" ]; then
		rmmod u200 2> /dev/null
		rmmod wilink 2> /dev/null
	fi
	if [ -n "$MODULE_JING" ]; then
		rmmod drxvi314 2> /dev/null
	fi
	killall -1 jingle_manager 2> /dev/null
	killall -9 jingle_manager 2> /dev/null
	killall -9 eap_supplicant 2> /dev/null
	rm -f $WIMAX_STATUS 2> /dev/null
	rm -f $WIMAX_LINKFILE 2> /dev/null
	rm -f $JINGLE_LINK_STATUS 2> /dev/null
	rm -f $KEY_LINK_STATUS 2> /dev/null
	rm -f $WIMAX_FWVER 2> /dev/null
	rm -f $JINGLE_FWVER 2> /dev/null
	rm -f $KEY_FWVER 2> /dev/null
}

unlock_and_exit() {
	rm -f $WIMAX_LOCK 2> /dev/null
	exit
}

case $MODEM in
"Samsung SWC-U200")
	echo $MODEM > $WIMAX_STATUS
	if [ -n "$MODULE_JING" ]; then
		killall -1 jingle_manager 2> /dev/null
		killall -9 jingle_manager 2> /dev/null
		killall -9 eap_supplicant 2> /dev/null
		rmmod drxvi314 2> /dev/null
		rm -f $JINGLE_LINK_STATUS 2> /dev/null
		rm -f $JINGLE_FWVER 2> /dev/null
	fi
	if [ ! -n "$MODULE_SAMS" ]; then
		insmod $LINKMOD 2> /dev/null
		insmod $UMOD_SAMS 2> /dev/null
	fi
	usb_device
	iwpriv $BOARD_INTERFACE_WAN big_diode 1 2> /dev/null
	iwpriv $BOARD_INTERFACE_WAN fw_ver | grep VER | cut -f2 -d"-" > $WIMAX_FWVER
	ifconfig $BOARD_INTERFACE_WAN up 2> /dev/null
	sleep 2
	iwconfig $BOARD_INTERFACE_WAN ap FF:FF:FF:FF:FF:FF 2> /dev/null
	sleep 4
	iwlist $BOARD_INTERFACE_WAN scan 2> /dev/null
	sleep 2
	COUNT=6
	while [ true ]; do
		CONNECT_STATUS=`iwpriv $BOARD_INTERFACE_WAN stat_connect | cut -f2 -d:`
		echo $CONNECT_STATUS > $WIMAX_CONNECT_STATUS
		if [ $CONNECT_STATUS = 0 ]; then
			iwconfig $BOARD_INTERFACE_WAN ap FF:FF:FF:FF:FF:FF 2> /dev/null
			sleep 10
			iwlist $BOARD_INTERFACE_WAN scan 2> /dev/null
			COUNT=$((COUNT-1))
			if [ $COUNT = 0 ]; then
				break
			fi
		else
			break
		fi
	done
	iwpriv $BOARD_INTERFACE_WAN big_diode 0 2> /dev/null
	if [ "init" != "$1" ]; then
		/bin/link_up.sh
	fi
	if [ $CONNECT_STATUS = 1 ]; then
		cp /proc/uptime $WIMAX_LINKFILE
	fi
	if [ $CONNECT_STATUS = 1 ] && [ -x $YOTA_READY ]; then
		$YOTA_READY start
	fi
	;;

"Yota Jingle WU217")
	if [ "init" = "$1" ]; then
		CHK_RUN=`ps ax| grep -v grep| grep jingle_manager`
		if [ -n "$CHK_RUN" ]; then
			echo $MODEM > $WIMAX_STATUS
			usb_device
			unlock_and_exit
		fi
	fi
	echo 0 > $WIMAX_CONNECT_STATUS
	echo $MODEM > $WIMAX_STATUS
	if [ ! -n "$MODULE_JING" ]; then
		insmod $UMOD_JING 2> /dev/null
	fi
	usb_device

	killall -1 jingle_manager 2> /dev/null
	killall -9 jingle_manager 2> /dev/null
	killall -9 eap_supplicant 2> /dev/null
	sleep 1
	jingle_manager &
	;;

"Yota One")
	if [ ! -e '/dev/usbwimax0' ]; then
		wimax_down
		unlock_and_exit
	fi

	echo $MODEM > $WIMAX_STATUS
	usb_device
	echo 0 > $WIMAX_CONNECT_STATUS

	/bin/link_up.sh

	COUNT=60
	while [ $COUNT != 0 ]; do
		COUNT=$((COUNT-1))
		grep -q 'Vendor=1076 ProdID=7708' $PROC_USB || \
		grep -q 'Vendor=0525 ProdID=a4a2' $PROC_USB || {
			COUNT=0
			break
		}

		gw=`route -n | grep -e "^0\\.0\\.0\\.0.*$BOARD_INTERFACE_WIMAX_LAN" | cut -c17-32 | cut -f1 -d\ `
		[ "$gw" != '' ] && ping -c 1 $gw 1>/dev/null && wget http://$gw/status -O $KEY_LINK_STATUS
		if [ -f $KEY_LINK_STATUS ]; then
			. $KEY_LINK_STATUS
			if [ -n "$MAC" ]; then
				echo $FirmwareVersion > $WIMAX_FWVER
				CONNECT_STATUS=0
				if [ "$State" = "Connected" ]; then
					CONNECT_STATUS=1
				fi
				echo $CONNECT_STATUS > $WIMAX_CONNECT_STATUS
				if [ $CONNECT_STATUS = 1 ]; then
					cp -f /proc/uptime $WIMAX_LINKFILE
					echo "MODEM_FWVER=$FirmwareVersion" > $KEY_FWVER
					MACA=`echo $MAC | cut -c1-2,4-5,7-8,10-11,13-14,16-17`
					echo "MODEM_MAC=$MACA">> $KEY_FWVER
					if [ -x $YOTA_READY ]; then
						$YOTA_READY start
					fi
					ledctl 1
					break
				fi
			fi
		else
			if [ $COUNT = 10 ]; then
				ifconfig wimax0 192.168.0.10/24 up
				route add default gw 192.168.0.1
				echo "nameserver 192.168.0.1" >/etc/resolv.conf
			fi
		fi

		sleep 2
	done ; \
	if [ $COUNT = 0 ]; then
		rm -f $WIMAX_LINKFILE 2> /dev/null
		rm -f $WIMAX_LOCK 2> /dev/null
		if [ -n "$MAC" ]; then
			/bin/link_up.sh
		else
			/bin/wimax-setup.sh &
		fi
		exit
	fi &
	;;

*)
	wimax_down
	;;
esac

rm -f $WIMAX_LOCK 2> /dev/null
