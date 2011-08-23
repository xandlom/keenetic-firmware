#!/bin/sh

DISK_LIST=`mount | grep media | cut -f3 -d" " | cut -f3 -d/`

ppp.sh die
sleep 1
killall -9 ppp-reinit.sh 2> /dev/null
killall -9 pppd.sh 2> /dev/null
killall -1 pppd 2> /dev/null
killall -9 pppd 2> /dev/null
killall -9 ppp.sh 2> /dev/null
rm -f /var/tmp/_pppd_sh 2> /dev/null

killall -9 wpa_supplicant 2> /dev/null
killall -1 jingle_manager 2> /dev/null
killall -1 eap_supplicant 2> /dev/null
sleep 1
killall -9 jingle_manager 2> /dev/null
killall -9 wimax-setup.sh 2> /dev/null
killall -9 8021x.sh 2> /dev/null
killall -9 cpeagent 2> /dev/null
killall -9 ddns.sh 2> /dev/null
dns.sh stop
killall -9 ntp.sh 2> /dev/null
killall -9 udhcpc 2> /dev/null
killall -9 udhcpd 2> /dev/null
killall -9 stupid-ftpd 2> /dev/null
killall -9 nmbd smbd 2> /dev/null
killall -9 p9100d p9101d p9102d 2> /dev/null

for disk in $DISK_LIST; do
	if [ "$disk" = "" ]; then
		continue
	fi
	umount /media/$disk 2> /dev/null
done

. /bin/iface-names.sh
ifconfig $BOARD_INTERFACE_WAN down 2> /dev/null
