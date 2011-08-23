#!/bin/sh

MODEM=""
DEV_LOCK=0
STOR_LOCK=0

# fix for Yota Jingle
sleep 1
grep -q 'Vendor=198f ProdID=0220' /proc/bus/usb/devices && DEV_LOCK=1
if [ $DEV_LOCK = 1 ]; then
	exit
fi

grep -q 'Vendor=12d1 ProdID=1003' /proc/bus/usb/devices && MODEM="HUAWEI"
grep -q 'Vendor=05c6 ProdID=1000' /proc/bus/usb/devices && MODEM="AnyDATA"
grep -q 'Vendor=19d2 ProdID=0103' /proc/bus/usb/devices && MODEM="ZTE112"
grep -q 'Vendor=19d2 ProdID=2000' /proc/bus/usb/devices && MODEM="ZTE626"
grep -q 'Vendor=1bbb ProdID=f000' /proc/bus/usb/devices && MODEM="AlcatelX060"
grep -q 'Vendor=1c9e ProdID=f000' /proc/bus/usb/devices && MODEM="AlcatelX100"
grep -q 'Vendor=12d1 ProdID=1446' /proc/bus/usb/devices && MODEM="HUAWEI_1550"
grep -q 'Vendor=1c9e ProdID=1001' /proc/bus/usb/devices && MODEM="AlcatelX020"
grep -q 'Vendor=19d2 ProdID=fff5' /proc/bus/usb/devices && MODEM="ZTE_AC5710"
grep -q 'Vendor=19d2 ProdID=fff6' /proc/bus/usb/devices && MODEM="ZTE_AC2726"
grep -q 'Vendor=16d8 ProdID=6803' /proc/bus/usb/devices && MODEM="CMOTECH"
grep -q 'Vendor=1edf ProdID=6003' /proc/bus/usb/devices && MODEM="MCD800"
grep -q 'Vendor=198f ProdID=bccd' /proc/bus/usb/devices && MODEM="WU217"
grep -q 'Vendor=22de ProdID=6801' /proc/bus/usb/devices && MODEM="WM_D200"

if [ $MODEM = "HUAWEI" ]; then
	grep -q 'Driver=option' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/old_usb_modeswitch -v 0x12d1 -p 0x1003 -H 1
	fi
fi

if [ $MODEM = "HUAWEI_1550" ]; then
	grep -q 'Driver=option' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/usb_modeswitch -v 0x12d1 -p 0x1446 -M 55534243123456780000000000000011060000000000000000000000000000
	fi
fi

if [ $MODEM = "AnyDATA" ]; then
	/bin/old_usb_modeswitch -v 0x05c6 -p 0x1000 -m 0x08 -M 5553424312345678000000000000061b000000020000000000000000000000
fi

if [ $MODEM = "ZTE112" ]; then
    /bin/usb_modeswitch -v 0x19d2 -p 0x0103 -n -M 5553424312345678240000008000061e000000000000000000000000000000 \
		-2 5553424312345679000000000000061b000000020000000000000000000000
fi

if [ $MODEM = "ZTE626" ]; then
    /bin/usb_modeswitch -v 0x19d2 -p 0x2000 -n -M 5553424312345678000000000000061e000000000000000000000000000000 \
		-2 5553424312345679000000000000061b000000020000000000000000000000 \
		-3 55534243123456782000000080000c85010101180101010101000000000000
fi

if [ $MODEM = "AlcatelX060" ]; then
	/bin/usb_modeswitch -v 0x1bbb -p 0xf000 -M 55534243123456788000000080000606f50402527000000000000000000000
fi

if [ $MODEM = "AlcatelX100" ]; then
	/bin/usb_modeswitch -v 0x1c9e -p 0xf000 -M 55534243123456788000000080000606f50402527000000000000000000000
fi

if [ $MODEM = "AlcatelX020" ]; then
	/bin/usb_modeswitch -v 0x1c9e -p 0x1001 -M 55534243123456788000000080000606f50402527000000000000000000000
fi

if [ $MODEM = "ZTE_AC5710" ]; then
	/bin/old_usb_modeswitch -v 0x19d2 -p 0xfff5 -m 0x05 -M 5553424312345678c00000008000069f030000000000000000000000000000
	grep -q 'Driver=option' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/old_usb_modeswitch -v 0x19d2 -p 0xfff5 -m 0xa -M 5553424312345678c00000008000069f030000000000000000000000000000
	fi
fi

if [ $MODEM = "ZTE_AC2726" ]; then
	/bin/old_usb_modeswitch -v 0x19d2 -p 0xfff6 -m 0xa -M 5553424312345678c00000008000069f030000000000000000000000000000
fi

if [ $MODEM = "CMOTECH" ]; then
	grep -q 'Driver=option' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/old_usb_modeswitch -v 0x16d8 -p 0x6803 -m 0x07 -M 555342431234567824000000800008ff524445564348470000000000000000
	fi
fi

if [ $MODEM = "MCD800" ]; then
	grep -q 'Driver=cdc-acm' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/old_usb_modeswitch -v 0x1edf -p 0x6003 -d 1 -u 2
	fi
fi

if [ $MODEM = "WM_D200" ]; then
	grep -q 'Driver=option' /proc/bus/usb/devices && STOR_LOCK=1
	if [ $STOR_LOCK = 0 ]; then
		/bin/old_usb_modeswitch -v 0x22de -p 0x6801 -d 1 -u 2
	fi
fi

if [ $MODEM = "WU217" ]; then
	/bin/old_usb_modeswitch -v 0x198f -p 0xbccd -m 0x02 -M 55534243f0298d8124000000800006bc626563240000000000000000000000
	sleep 2
fi

wimax-setup.sh
