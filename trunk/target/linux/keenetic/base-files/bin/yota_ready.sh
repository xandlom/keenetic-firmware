#!/bin/sh
# Copyright (C) 2010 ZyXEL.RU, McMCC

SERVICE="yota"
JINGLE_FWVER=/var/tmp/jingle_fwver
KEY_FWVER=/var/tmp/key_fwver
RESULTFILE=/var/tmp/yota_ready.status
PROC_USB=/proc/bus/usb/devices

stop() {
	rm -f $RESULTFILE 2> /dev/null
	PROC=`ps | grep -v grep | grep updatedd | grep $SERVICE| cut -f1 -d"r"`
	if [ -n "$PROC" ]; then
		kill -9 $PROC
	fi
}

start() {
	stop
	. /etc/version
	TYPE=0
	grep -q 'Vendor=198f ProdID=0220' $PROC_USB && TYPE=1
	grep -q 'Vendor=1076 ProdID=7708' $PROC_USB && TYPE=2
	if [ $TYPE = 1 ]; then
		if [ -f $JINGLE_FWVER ]; then
			. $JINGLE_FWVER
		else
			exit
		fi
	elif [ $TYPE = 2 ]; then
		if [ -f $KEY_FWVER ]; then
			. $KEY_FWVER
		else
			exit
		fi
	else
		MODEM_FWVER=`iwpriv wimax0 fw_ver | grep VER | cut -f2 -d"-"`
		MODEM_MAC=`iwpriv wimax0 fw_ver | grep MAC | cut -f2 -d" "`
	fi
	updatedd -- $SERVICE -d $DEVICE_NAME -f $FIRMWARE_VERSION -m $MODEM_MAC -F $MODEM_FWVER > $RESULTFILE 2>&1 &
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	*)
		echo "Usage: $0 {start|stop}"
		;;
esac
