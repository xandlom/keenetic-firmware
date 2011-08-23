#!/bin/sh

SGDEV=0

grep -q 'Vendor=1c9e ProdID=1001' /proc/bus/usb/devices && SGDEV=1


if [ $SGDEV = 1 ]; then
	modem-switcher.sh
fi
