#!/bin/sh

. /bin/iface-names.sh

if [ "$1" != "ttyUSB0" ] && [ "$1" != "ttyACM0" ]; then
	exit
fi

DEVTTY=$1
DEVTTYFILE=/var/tmp/devtty
MODEM_STATUS=/var/usbstatus/modem
MODEM_TYPE=/var/usbstatus/modem_type
MODEM_AT_SETUP=/var/usbstatus/modem_at_setup
MODEM_STATUS_TMP=/var/usbstatus/modem.tmp
PRINTER_STATUS=/var/usbstatus/printer
STORAGE_STATUS=/var/usbstatus/storage
WIMAX_STATUS=/var/usbstatus/wimax
MODEM=0

usb_device() {
	ls /dev/$DEVTTY >/dev/null 2>&1 || {
		rm -f $MODEM_STATUS_TMP $MODEM_STATUS 2> /dev/null
	}
	if [ -f $PRINTER_STATUS ] || [ -f $STORAGE_STATUS ] || [ -f $WIMAX_STATUS ]; then
		ledctl 12
	else
		ledctl 13
	fi
	if [ $MODEM != 0 ]; then
		ls /dev/$DEVTTY >/dev/null 2>&1 && { 
			cp -f $MODEM_STATUS_TMP $MODEM_STATUS 2> /dev/null
			rm -f $MODEM_STATUS_TMP 2> /dev/null
			ledctl 12 
		}
	fi
}

zted_setup() {
	ZTE_ACT=`ps | grep -v grep | grep zted`
	if [ $MODEM = 4 ]; then
		if [ -z "$ZTE_ACT" ]; then
			/bin/zted
		fi
	else
		if [ ! -z "$ZTE_ACT" ]; then
			killall zted
		fi
	fi
}

modem_unlock() {
	eval `flash MODEM_ENABLED`

	if [ -f /var/tmp/modem.lock ]; then
		exit
	fi

	grep -q 'Vendor=12d1 ProdID=1003' /proc/bus/usb/devices && MODEM=1
	grep -q 'Vendor=16d5 ProdID=6501' /proc/bus/usb/devices && MODEM=2
	grep -q 'Vendor=16d5 ProdID=6502' /proc/bus/usb/devices && MODEM=3
	grep -q 'Vendor=19d2 ProdID=0001' /proc/bus/usb/devices && MODEM=4
	grep -q 'Vendor=19d2 ProdID=0031' /proc/bus/usb/devices && MODEM=4
	grep -q 'Vendor=19d2 ProdID=0016' /proc/bus/usb/devices && MODEM=4
	grep -q 'Vendor=19d2 ProdID=2003' /proc/bus/usb/devices && MODEM=4
	grep -q 'Vendor=1bbb ProdID=0000' /proc/bus/usb/devices && MODEM=5
	grep -q 'Vendor=1c9e ProdID=9603' /proc/bus/usb/devices && MODEM=6
	grep -q 'Vendor=12d1 ProdID=1001' /proc/bus/usb/devices && MODEM=7
	grep -q 'Vendor=1c9e ProdID=6061' /proc/bus/usb/devices && MODEM=8
	grep -q 'Vendor=16d8 ProdID=5543' /proc/bus/usb/devices && MODEM=9
	grep -q 'Vendor=1529 ProdID=3100' /proc/bus/usb/devices && MODEM=10
	grep -q 'Vendor=16d8 ProdID=6533' /proc/bus/usb/devices && MODEM=11
	grep -q 'Vendor=1726 ProdID=1000' /proc/bus/usb/devices && MODEM=12
	grep -q 'Vendor=1edf ProdID=6004' /proc/bus/usb/devices && MODEM=13
	grep -q 'Vendor=19d2 ProdID=ffff' /proc/bus/usb/devices && MODEM=14
	grep -q 'Vendor=1edf ProdID=6003' /proc/bus/usb/devices && MODEM=15
	grep -q 'Vendor=211f ProdID=6801' /proc/bus/usb/devices && MODEM=16
	grep -q 'Vendor=16d8 ProdID=6803' /proc/bus/usb/devices && MODEM=17
	grep -q 'Vendor=19d2 ProdID=fffe' /proc/bus/usb/devices && MODEM=18
	grep -q 'Vendor=12d1 ProdID=14ac' /proc/bus/usb/devices && MODEM=19
	grep -q 'Vendor=22de ProdID=6801' /proc/bus/usb/devices && MODEM=20
	grep -q 'Vendor=19d2 ProdID=fff1' /proc/bus/usb/devices && MODEM=21
	grep -q 'Vendor=12d1 ProdID=140c' /proc/bus/usb/devices && MODEM=22
	grep -q 'Vendor=12d1 ProdID=1436' /proc/bus/usb/devices && MODEM=22
	grep -q 'Vendor=19d2 ProdID=0117' /proc/bus/usb/devices && MODEM=23
	rm -f $DEVTTYFILE 2> /dev/null
	rm -f $MODEM_TYPE 2> /dev/null

	if [ -x "/bin/zted" ]; then
		zted_setup
	fi
	
	if [ $MODEM = 0 ]; then
		usb_device
		exit
	fi

	touch /var/tmp/modem.lock
	echo "NONE" > $MODEM_STATUS_TMP
	DEVTTY=ttyUSB0
	case $MODEM in
	4)
		DEVTTY=ttyUSB2
		# fix for ZTE MF627
		if [ -e "/dev/ttyUSB3" ]; then
			DEVTTY=ttyUSB3
		fi
		;;
	5|6)
		DEVTTY=ttyUSB2
		;;
	9|10|11|13|15) 
		DEVTTY=ttyACM0
		;;
	23)
		DEVTTY=ttyUSB1
		;;
	esac
	sleep 2
	rm /var/tmp/modem.lock 2> /dev/null
	echo -n "$DEVTTY" > $DEVTTYFILE
}


modem_at_setup() {
	case $MODEM in
	1|4|5|6|7|8|19|22|23)
		echo "'OK' 'AT+CFUN=1'" > $MODEM_AT_SETUP
		# echo "'OK' 'AT+CMEE=2'" >> $MODEM_AT_SETUP
		# echo "'OK' 'AT+CGQREQ=1,0,0,0,0,0'" >> $MODEM_AT_SETUP
		# echo "'OK' 'AT+CGQMIN=1,0,0,0,0,0'" >> $MODEM_AT_SETUP
		# echo "'OK' 'AT+CGATT=1'" >> $MODEM_AT_SETUP
		;;
	2|3)
		echo "'OK' 'ATI'" > $MODEM_AT_SETUP
		echo "'OK' 'AT+CRM=1'" >> $MODEM_AT_SETUP
		;;
	9|10|11|12|13|14|15|16|17|18|20)
		echo "'OK' 'AT+CRM=1'" > $MODEM_AT_SETUP
		;;
	21)
		echo "'OK' 'ATE0V1'" > $MODEM_AT_SETUP
		echo "'OK' 'ATS0=0'" >> $MODEM_AT_SETUP
		;;
	*)
		rm -f $MODEM_AT_SETUP 2> /dev/null
		;;
	esac
}

modem_type() {
	case $MODEM in
	1)
		echo "Huawei E160G/E2xx/E1550" > $MODEM_TYPE
		;;
	2)
		echo "AnyDATA ADU-3x0A" > $MODEM_TYPE
		;;
	3)
		echo "AnyDATA ADU-5x0A" > $MODEM_TYPE
		;;
	4)
		echo "ZTE MF100/MF112/MF18x/MF6xx" > $MODEM_TYPE
		;;
	5)
		echo "Alcatel X060S" > $MODEM_TYPE
		;;
	6)
		echo "Alcatel X100/U12(Crescent)" > $MODEM_TYPE
		;;
	7)
		echo "Huawei E620/E155x/E1750" > $MODEM_TYPE
		;;
	8)
		echo "Alcatel OT-X020" > $MODEM_TYPE
		;;
	9)
		echo "C-motech CNU-550" > $MODEM_TYPE
		;;
	10)
		echo "UBIQUAM" > $MODEM_TYPE
		;;
	11)
		echo "C-motech CNM-650" > $MODEM_TYPE
		;;
	12)
		echo "AxessTel MV110NR" > $MODEM_TYPE 
		;;
	13)
		echo "Airplus MCD-650" > $MODEM_TYPE 
		;;
	14)
		echo "ZTE AC5710" > $MODEM_TYPE 
		;;
	15)
		echo "Airplus MCD-800/Withtel WMU-100A" > $MODEM_TYPE 
		;;
	16)
		echo "CELOT CT-650/CT-680" > $MODEM_TYPE 
		;;
	17)
		echo "C-motech CNU-680" > $MODEM_TYPE 
		;;
	18)
		echo "ZTE MG478" > $MODEM_TYPE 
		;;
	19)
		echo "Huawei E15x/E1820" > $MODEM_TYPE 
		;;
	20)
		echo "WeTelecom WM-D200" > $MODEM_TYPE 
		;;
	21)
		echo "ZTE AC2726" > $MODEM_TYPE 
		;;
	22)
		echo "Huawei E173/E155x" > $MODEM_TYPE 
		;;
	23)
		echo "ZTE MF658" > $MODEM_TYPE 
		;;
	*)
		rm -f $MODEM_TYPE 2> /dev/null
		;;
	esac
}

mkdir -p /var/usbstatus 2> /dev/null
modem_unlock
usb_device
modem_type
modem_at_setup
