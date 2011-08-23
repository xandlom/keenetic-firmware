#!/bin/sh

run() {
	command -v $1 >/dev/null || exit 1
	echo "================================================================================"
	echo "# $*"
	echo "--------------------------------------------------------------------------------"
	$*
	echo
}

runif() {
	[ -e $1 ] || command -v $1 >/dev/null || return
	shift; run $*
}

runcat() {
	for file; do [ -e $file ] && run cat $file; done
}

dump() {
	runcat /etc/version
	run flash all

	if [ "$DEVICE_NAME" = "KEENETIC-GIGA" ]; then
		run switch arl
		run switch vlan
		run switch vlan_eg
		run switch vlan_in
		run switch pvid
	else
		run switch dump
		run switch vlan dump
		run switch vlantag dump
		run switch vlanen dump
		run switch pvid dump
	fi

	run cli sys status
	run cli sys ports
	runif vdsl_ctrl cli vdsl status
	run arp -avn
	run route -n
	run ifconfig -a
	run iwconfig
	run netstat -aenW

	run iptables -L -vn
	run iptables -t nat -L -vn
	run iptables -t mangle -L -vn

	runcat /etc/resolv.conf /var/udhcpc/resolv.conf /etc/ppp/resolv.conf
	runcat /etc/hosts /etc/dnrd/master
	runcat 

	run top -b -n 1
	run ps

	run lsmod
	runcat /proc/modules

	runcat /proc/uptime /proc/meminfo /proc/cpuinfo /proc/version
	runcat /proc/bus/usb/devices

	run mount
	run df

	run ls /media
	run ls -l /var/tmp
	run ls -l /var/run
	run ls -l /storage
	run ls -l /lib/modules/2.6.23-rt/

	runcat /var/tmp/RT2860.dat /var/igmpproxy.conf /var/igmpsn.cfg

	runcat /var/tmp/pppstatus /var/tmp/pppresult /etc/ppp/options /etc/ppp/pap-secrets
	runcat /etc/ppp/chap-secrets /etc/ppp/l2tp-secrets /etc/ppp/connectfile
	runcat /etc/ppp/modem.chat /var/usbstatus/modem /var/usbstatus/modem_type
	runcat /var/usbstatus/printer /var/usbstatus/storage /var/usbstatus/wimax
	runcat /var/usbstatus/wimax_fwver /var/usbstatus/wimax_connect_status 
	runcat /var/tmp/jingle_status /var/tmp/jingle_fwver /var/tmp/key_status /var/tmp/key_fwver 
	runcat /var/udhcpd.conf /tmp/smbpasswd /tmp/smb.conf
	runcat /var/tmp/zyntp.log /var/tmp/transmission_status
	runcat /var/vsftpd.conf /var/vsftpd.passwd /etc/TZ

	echo "================================================================================"
	echo "-- END --"
}

. /etc/version
if [ $# -gt 0 ]; then
	dump >$1
else
	dump
fi
