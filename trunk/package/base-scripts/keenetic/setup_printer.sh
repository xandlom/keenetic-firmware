#!/bin/sh

eval `flash LAN_IP_ADDR PRINTSERVER_ENABLED`

PRINTER_DEV=/dev/usblp0
FIRMWARE=/storage/lp_firmware.bin
MODEM_STATUS=/var/usbstatus/modem
PRINTER_STATUS=/var/usbstatus/printer
STORAGE_STATUS=/var/usbstatus/storage
WIMAX_STATUS=/var/usbstatus/wimax

# Support only one printer!
if [ "$1" != "lp0" ] && [ "$1" != "" ]; then
	exit
fi

usb_device() {
	ls $PRINTER_DEV >/dev/null 2>&1 || rm -f $PRINTER_STATUS 2> /dev/null
	ls $PRINTER_DEV >/dev/null 2>&1 && cat /dev/null > $PRINTER_STATUS 
	if [ -f $PRINTER_STATUS ] || [ -f $MODEM_STATUS ] || [ -f $STORAGE_STATUS ] || [ -f $WIMAX_STATUS ]; then
		ledctl 12
	else
		ledctl 13
	fi
}

load_firmware() {
	if [ -f $FIRMWARE ]; then
		cat $FIRMWARE > /dev/usblp0
	fi
}

stop_printserver() {
	usb_device
	killall -9 p9100d p9101d p9102d 2> /dev/null
}

start_printserver() {
	stop_printserver
	load_firmware
	p910nd -f $PRINTER_DEV -b -i $LAN_IP_ADDR
}

mkdir -p /var/usbstatus 2> /dev/null
iptables -D INPUT -p tcp --dport 9100 -j ACCEPT 2> /dev/null
if [ "$PRINTSERVER_ENABLED" = "Enabled" ]; then
	ls $PRINTER_DEV >/dev/null 2>&1 || stop_printserver 
	ls $PRINTER_DEV >/dev/null 2>&1 && start_printserver 
	if [ "$PRINTSERVER_WAN_ACCESS_ENABLED" = 'Enabled' ] && [ "$OP_MODE" != 'WiFi Access Point' ] && [ "$OP_MODE" != 'Wireless Bridge' ];then
		iptables -A INPUT -p tcp --dport 9100 -j ACCEPT
	fi
else
	stop_printserver
fi
