#!/bin/sh

LOCKFILE="/var/tmp/init.lock"

trap "rm -fr $LOCKFILE 2>/dev/null" EXIT INT TERM HUP

mkdir $LOCKFILE 2>/dev/null || {
	echo "init.sh is running now"
	exit
}

WIMAX_STATUS=/var/usbstatus/wimax

hostname_hosts () {
	HOSTNAME="zyxel-router"
	if [ -n "$DEVICE_NAME" ]; then
		HOSTNAME=$DEVICE_NAME
	fi
	if [ -n "$HOST_NAME" ]; then
		HOSTNAME=$HOST_NAME
	fi
	hostname $HOSTNAME
	echo "127.0.0.1 localhost" > /etc/hosts
	echo "$LAN_IP_ADDR $HOSTNAME" >> /etc/hosts
}

clean_services () {
	PPPFIFO=/var/tmp/ppp_fifo
	PPPKILL=/var/tmp/ppp_kill
	PPPLINKFILE=/etc/ppp/link
	PPPSTATUSFILE=/var/tmp/pppstatus
	PPPRESULTFILE=/var/tmp/pppresult
	PPPCHAINFILE=/var/tmp/pppchain
	PPPOPTIONS=/etc/ppp/options
	PAPFILE=/etc/ppp/pap-secrets
	CHAPFILE=/etc/ppp/chap-secrets
	L2TPFILE=/etc/ppp/l2tp-secrets
	PPPCONNECTFILE=/etc/ppp/connectfile
	PPTPNUMFILE=/var/pptpnum
	PPPCHAT=/etc/ppp/modem.chat
	MODEM_AT_SETUP=/var/usbstatus/modem_at_setup
	PPPDEVTTYFILE=/var/tmp/devtty

	ledctl 2
	ppp.sh die
	sleep 1
	killall -9 pppd.sh 2> /dev/null
	killall -1 pppd 2> /dev/null
	killall -9 pppd 2> /dev/null
	killall -9 ppp.sh 2> /dev/null
	rm -f /var/tmp/_pppd_sh 2> /dev/null
	rm -f /etc/ppp/resolv.conf 2> /dev/null
	rm -f /var/udhcpc/resolv.conf 2> /dev/null
	rm -f $PPPLINKFILE $PPPCONNECTFILE $PPPFIFO $PPPKILL $PPPSTATUSFILE $PPTPNUMFILE $PPPCHAT 2> /dev/null
	rm -f $PPPRESULTFILE $PPPCHAINFILE $PPPOPTIONS $PAPFILE $CHAPFILE $L2TPFILE $MODEM_AT_SETUP 2> /dev/null
	rm -f $PPPDEVTTYFILE 2> /dev/null
	killall wpa_supplicant 2> /dev/null
	sleep 1
	killall -9 wpa_supplicant 2> /dev/null
	killall -9 8021x.sh 2> /dev/null

	for interface in $BOARD_INTERFACE_WIRELESS_LAN $BOARD_INTERFACE_ETH_WAN $BOARD_INTERFACE_WIMAX_LAN; do
		PIDFILE=/etc/udhcpc/udhcpc-$interface.pid
		if [ -f $PIDFILE ] ; then
			PID=`cat $PIDFILE`
			if [ $PID != 0 ]; then
				kill -9 $PID 2> /dev/null
			fi
			rm -f $PIDFILE
		fi
	done

	PIDFILE=/var/run/udhcpd.pid
	if [ -f $PIDFILE ] ; then
		PID=`cat $PIDFILE`
		if [ $PID != 0 ]; then
			kill -USR1 $PID 2> /dev/null
			kill -9 $PID 2> /dev/null
		fi
		rm -f $PIDFILE
	fi
}

start_lan_services() {

	fixedip.sh $BOARD_INTERFACE_LAN $LAN_IP_ADDR $LAN_SUBNET_MASK $LAN_DEFAULT_GATEWAY

	if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' ]; then
		killall -15 miniupnpd 2> /dev/null
		dns.sh stop
		killall ntp.sh 2> /dev/null
		killall servtag.sh 2> /dev/null
		killall ddns.sh 2> /dev/null
		iptables -F
		iptables -t nat -F PREROUTING
		iptables -t nat -F POSTROUTING
		iptables -t nat -F STB 2> /dev/null
		iptables -t nat -X STB 2> /dev/null
		iptables -F INPUT
		iptables -F OUTPUT
		iptables -F FORWARD
		iptables -F STB 2> /dev/null
		iptables -X STB 2> /dev/null
		iptables -P OUTPUT ACCEPT
		iptables -P INPUT ACCEPT
		iptables -P FORWARD ACCEPT
		RESOLV=/etc/resolv.conf
		:> $RESOLV
		if [ -n "$LAN_DEFAULT_GATEWAY" ] && [ "$LAN_DEFAULT_GATEWAY" != "0.0.0.0" ]; then
			DNS_ENABLE=0
			if [ "$WAN_DNS1" != '0.0.0.0' ]; then
				echo "nameserver $WAN_DNS1" >> $RESOLV
				DNS_ENABLE=1
			fi
			if [ "$WAN_DNS2" != '0.0.0.0' ]; then
				echo "nameserver $WAN_DNS2" >> $RESOLV
				DNS_ENABLE=1
			fi
			if [ "$WAN_DNS3" != '0.0.0.0' ]; then
				echo "nameserver $WAN_DNS3" >> $RESOLV
				DNS_ENABLE=1
			fi
			if [ $DNS_ENABLE = 1 ]; then
				ntp.sh
				servtag.sh
			fi
		fi
	fi

	if [ "$LAN_DHCP_MODE" = 'Server' ]; then
		dhcpd.sh
	fi
}

start_wan_services() {
	if [ "$OP_MODE" = 'Ethernet Router' ]; then
		insmod /lib/modules/2.6.23-rt/fastnat.ko 2> /dev/null
	else
		rmmod fastnat 2> /dev/null
	fi

	if [ "$EZTUNE_ENABLED" = 'Enabled' ] && [ "$OP_MODE" = 'Ethernet Router' ] && [ "$PPP_TYPE" = 'None' ]; then
		eztune.sh up
	else
		eztune.sh down
	fi

	dns.sh

	if [ "$WAN_DOT1X_ENABLED" = 'Enabled' ]; then
		8021x.sh
	fi

	if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
		PPP_TYPE='None'
	fi

	if [ "$OP_MODE" = 'WiMAX Router' ] && [ ! -f $WIMAX_STATUS ]; then
		# Unknown
		WAN_IP_ADDRESS_MODE=3
	fi

	if [ "$OP_MODE" = '3G Router' ]; then
		ppp.sh start
	elif [ "$WAN_IP_ADDRESS_MODE" = 'Static' ]; then
		fixedip.sh $BOARD_INTERFACE_WAN $WAN_IP_ADDR $WAN_SUBNET_MASK $WAN_DEFAULT_GATEWAY
		if [ "$PPP_TYPE" != 'None' ]; then
			ppp.sh start
		else
			ledctl 1
		fi
	elif [ "$WAN_IP_ADDRESS_MODE" = 'Auto' ]; then
		dhcpc.sh $BOARD_INTERFACE_WAN &
	elif [ "$WAN_IP_ADDRESS_MODE" = 'No IP' ]; then
		if [ "$PPP_TYPE" = 'PPPoE' ]; then
			ppp.sh start
		fi
	fi	

	killall firewall.sh 2> /dev/null
	firewall.sh

	killall ntp.sh 2> /dev/null
	ntp.sh
	killall ddns.sh 2> /dev/null
	ddns.sh
	killall servtag.sh 2> /dev/null
	servtag.sh

	route.sh
	igmpproxy.sh
}

start_wide_services() {
	setup_users.sh
	setup_printer.sh
	if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = '3G Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
		upnp.sh
	fi

}

wan_link_monitor() {
	LINKMOD=/lib/modules/2.6.23-rt/swlink.ko
	MODULE=`lsmod | grep swlink`
	if [ -n "$MODULE" -a "$OP_MODE" != 'Ethernet Router' ]; then
		rmmod swlink
	fi

	if [ "$OP_MODE" = 'Ethernet Router' ] && [ ! -n "$MODULE" ] && [ -f "$LINKMOD" ]; then
		insmod $LINKMOD
	fi
}

check_change_port() {
	# Web
	SAVE_WEB_PORT="/var/websv_port"
	if [ -f $SAVE_WEB_PORT ]; then
		eval `flash WEB_WAN_ACCESS_PORT`
		WEB_PORT=`cat $SAVE_WEB_PORT`
		if [ "$WEB_WAN_ACCESS_PORT" != "$WEB_PORT" ]; then
			echo -n $WEB_WAN_ACCESS_PORT > $SAVE_WEB_PORT
			killall -9 websv 2> /dev/null
			launch "/bin/watcher /bin/websv -p $WEB_WAN_ACCESS_PORT&"
		fi
	fi
	# Telnet
	SAVE_TELNET_PORT="/var/telnet_port"
	if [ -f $SAVE_TELNET_PORT ]; then
		eval `flash TELNET_ACCESS_PORT`
		TELNET_PORT=`cat $SAVE_TELNET_PORT`
		if [ "$TELNET_ACCESS_PORT" != "$TELNET_PORT" ]; then
			echo -n $TELNET_ACCESS_PORT > $SAVE_TELNET_PORT
			kill -9 `ps|grep -v grep|grep telnetd|grep cli|cut -f1 -d "r"` 2> /dev/null
			launch "/usr/sbin/telnetd -l /bin/cli -p $TELNET_ACCESS_PORT&"
		fi
	fi
}

syslog.sh no_flash

insmod /lib/modules/2.6.23-rt/rtled.ko power_on=1 2> /dev/null

flash autofix

eval `flash OP_MODE PPP_TYPE DEVICE_NAME HOST_NAME \
LAN_DHCP_MODE LAN_IP_ADDR LAN_SUBNET_MASK LAN_DEFAULT_GATEWAY \
WAN_IP_ADDRESS_MODE WAN_IP_ADDR WAN_SUBNET_MASK WAN_DEFAULT_GATEWAY \
WAN_DOT1X_ENABLED WAN_MAC_ADDR WAN_DNS1 WAN_DNS2 WAN_DNS3 EZTUNE_ENABLED`

syslog.sh

killall -USR1 websv 2> /dev/null

hostname_hosts

. /bin/iface-names.sh

if [ -f /lib/modules/2.6.23-rt/hw_nat.ko ]; then
	WMODULE=`lsmod | grep rt2860 | cut -d " " -f 1`
	if [ -n "$WMODULE" ]; then
		ifconfig $BOARD_INTERFACE_WIRELESS_LAN down 2> /dev/null
		rmmod hw_nat 2> /dev/null
		rmmod $WMODULE 2> /dev/null
	else
		rmmod hw_nat 2> /dev/null
	fi
fi

check_change_port

WAN_STATUS=/var/tmp/wan_iface
echo "down" > $WAN_STATUS

SAVE_IP="/var/udhcpc/saveip*"
rm -f $SAVE_IP 2> /dev/null

clean_services

wlan.sh

bridge.sh

start_lan_services

wimax-setup.sh init

if [ "$OP_MODE" = 'WiFi Access Point' ]; then
	# Fix for working IPTV on WiFi in AP mode.
	iwpriv $BOARD_INTERFACE_WIRELESS_LAN set IgmpSnEnable=1 >/dev/null 2>&1
fi

if [ -f /lib/modules/2.6.23-rt/hw_nat.ko ]; then
	if [ "$OP_MODE" = 'Ethernet Router' ]; then
		insmod /lib/modules/2.6.23-rt/hw_nat.ko 2> /dev/null
		echo "add,$BOARD_INTERFACE_ETH_WAN,1" > /proc/net/hwnat_stat_uid
		echo "add,$BOARD_INTERFACE_ETH_LAN,1" > /proc/net/hwnat_stat_uid
		echo "add,br0,1,1" > /proc/net/hwnat_stat_uid
	fi
fi

if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = '3G Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
	start_wan_services
else
	IGMPSN=/lib/modules/2.6.23-rt/igmpsn.ko
	if [ -f $IGMPSN ]; then
		# Load IGMP Snooping module
		igmpproxy.sh
	fi
fi

wan_link_monitor

wlan_acl.sh

start_wide_services

if [ "$OP_MODE" = 'Ethernet Router' -o "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = '3G Router' -o "$OP_MODE" = 'WiMAX Router' ]; then
	# Set WPS mode on.
	eval `flash WLAN_WPS_CONFIGURED`
	if [ $WLAN_WPS_CONFIGURED = 0 ]; then
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfMode=7 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfStatus=1 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscMode=1 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscStatus=0 >/dev/null 2>&1
	else
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfMode=7 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscConfStatus=2 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscMode=1 >/dev/null 2>&1
		iwpriv $BOARD_INTERFACE_WIRELESS_LAN set WscStatus=0 >/dev/null 2>&1
	fi
fi

rm -f $WAN_STATUS

# Daemon to monitor reset button and reset config
killall -9 btnreset 2> /dev/null
watcher /bin/btnreset &

INIT=/media/DISK_A1/system/bin/ext_init.sh

if [ -x $INIT ]; then
	$INIT restart init 2> /dev/null &
fi
