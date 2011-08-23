#!/bin/sh

. /bin/iface-names.sh

WAN=$BOARD_INTERFACE_WAN
BRIDGE=$BOARD_INTERFACE_LAN

eval `flash OP_MODE PPP_TYPE WAN_IP_ADDRESS_MODE DMZ_HOST LAN_SUBNET_MASK LAN_IP_ADDR \
URLFILTER_ENABLED IPFILTER_MODE PORTFILTER_ENABLED MACFILTER_MODE \
PORTFW_ENABLED DMZ_ENABLED LAN_IP_ADDR WAN_TTL_INC_ENABLED WAN_AUTO_QOS_ENABLED DHCP_O60_TBL_NUM`

iptables -F
iptables -t nat -F PREROUTING
iptables -t nat -F POSTROUTING
iptables -t nat -F STB 2> /dev/null
iptables -t nat -X STB 2> /dev/null
iptables -t mangle -F PREROUTING
iptables -t mangle -F POSTROUTING
iptables -t mangle -F INPUT
iptables -t mangle -F OUTPUT
iptables -t mangle -F FORWARD
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -F STB 2> /dev/null
iptables -X STB 2> /dev/null
iptables -P OUTPUT ACCEPT

# In bridge mode, we don't need firewall
if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' ] ; then
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	exit
fi

# YOTA WiMAX
if [ "$OP_MODE" = 'WiMAX Router' ] ; then
	PPP_TYPE='None'
fi

# fix for USB modems
usb_modem_config() {
	if [ "$OP_MODE" = '3G Router' ] ; then
		PPP_TYPE=5
		WAN=ppp0
		BOARD_INTERFACE_WAN=ppp0
		PHY_WAN=""
		PHY_WAN_IP=""
	fi
}
usb_modem_config

get_ip_config() {
	if [ "$PPP_TYPE" != 'None' ]; then
		WAN_T1=`ifconfig | grep ppp0`
		if [ -n "$WAN_T1" ]; then
			WAN=`echo $WAN_T1 | cut -f 1 -d" "`
		fi
		PHY_WAN=$BOARD_INTERFACE_WAN
		PHY_WAN_IP=`ifconfig $PHY_WAN 2> /dev/null | grep -i "inet addr:" | cut -f2 -d: | cut -f1 -d " "`
	fi
	EXT_IP=`ifconfig $WAN 2> /dev/null | grep -i "inet addr:" | cut -f2 -d: | cut -f1 -d " "`
	INT_IP=`ifconfig $BRIDGE 2> /dev/null | grep -i "inet addr:" | cut -f2 -d: | cut -f1 -d " "`
	if [ "$WAN_IP_ADDRESS_MODE" = 'No IP' ]; then
		if [ -e /bin/igmpproxy ]; then
			ifconfig $BOARD_INTERFACE_WAN 10.11.12.13 netmask 255.255.255.255 up
			iptables -A INPUT -i $BOARD_INTERFACE_WAN -m state --state ESTABLISHED,RELATED -j ACCEPT
			iptables -A FORWARD -i $BOARD_INTERFACE_WAN -j ACCEPT
			iptables -A INPUT -p igmp -i $BOARD_INTERFACE_WAN -j ACCEPT
		fi
		WAN=ppp0
		BOARD_INTERFACE_WAN=ppp0
		PHY_WAN=""
		PHY_WAN_IP=""
	fi
}
get_ip_config
usb_modem_config

set_nat() {
	iptables -P INPUT DROP
	iptables -P FORWARD DROP

	iptables -A INPUT -i $BRIDGE -j ACCEPT
	iptables -A FORWARD -i $BRIDGE -j ACCEPT

	for iface in $WAN $PHY_WAN; do
		iptables -A INPUT -i $iface -m state --state ESTABLISHED,RELATED -j ACCEPT
		iptables -A FORWARD -i $iface -j ACCEPT
		iptables -A INPUT -p igmp -i $iface -j ACCEPT
	done

	# In static ip mode, SNAT is more efficient than MASQUERADE
	if [ "$PPP_TYPE" = 'None' -a "$WAN_IP_ADDRESS_MODE" = 'Static' ]; then
		if [ -n "$EXT_IP" ]; then
			iptables -t nat -A POSTROUTING -o $WAN -j SNAT --to-source $EXT_IP
		fi
	else
		iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
		if [ -n "$PHY_WAN_IP" ]; then
			iptables -t nat -A POSTROUTING -o $PHY_WAN -j SNAT --to-source $PHY_WAN_IP
		fi
	fi
}
set_nat

set_filters() {
	if [ "$IPFILTER_MODE" != 'Disabled' ]; then
		case "$IPFILTER_MODE" in
		'Black list') todo=DROP ;;
		'White list') todo=ACCEPT ;;
		esac
		flash IPFILTER_TBL | while read line;
		do
			eval $line
			[ $proto = Both ] && proto="TCP UDP"
			for protocol in $proto; do
				iptables -I FORWARD -p $protocol -s $ip -j $todo
			done
		done
	fi

	if [ "$MACFILTER_MODE" != 'Disabled' ]; then
		case "$MACFILTER_MODE" in
		'Black list') todo=DROP ;;
		'White list') todo=ACCEPT ;;
		esac
		flash MACFILTER_TBL | while read line;
		do
			eval $line
			iptables -I FORWARD -m mac --mac-source $mac -j $todo
		done
	fi

	if [ "$URLFILTER_ENABLED" = 'Enabled' ]; then
		flash URLFILTER_TBL | while read line;
		do
			eval $line
			iptables -I FORWARD -i $BRIDGE -p tcp -m webstr --url "$url" -j DROP
		done
	fi

	if [ "$PORTFILTER_ENABLED" = 'Enabled' ]; then
		flash PORTFILTER_TBL | while read line;
		do
			eval $line
			[ $proto = Both ] && proto="TCP UDP"
			for iface in $WAN $PHY_WAN; do
				for protocol in $proto; do
					iptables -I FORWARD -i $BRIDGE -o $iface -p $protocol --dport $fromport:$toport -j DROP
				done
			done
		done
	fi

	if [ "$IPFILTER_MODE" = 'White list' -o "$MACFILTER_MODE" = 'White list' ]; then
		iptables -D FORWARD -i $BRIDGE -j ACCEPT
	fi
}
set_filters

set_forward() {	
	NET_IP=`zyut net_ip $LAN_IP_ADDR $LAN_SUBNET_MASK`
	cat /proc/net/arp | grep 0x6 | grep FF:FF:FF:FF:FF:FF | cut -f1 -d' ' | while read line; do
		arp -d $line 2> /dev/null
	done

	if [ "$PORTFW_ENABLED" = 'Enabled' ]; then
		flash PORTFW_TBL | while read line;
		do
			eval $line
			[ $proto = Both ] && proto="TCP UDP"
			for protocol in $proto; do
				if [ -n "$EXT_IP" ]; then
					iptables -A PREROUTING -t nat -p $protocol --dport $fromport:$toport -d $EXT_IP -j DNAT --to-destination $ip
				fi
				if [ -n "$PHY_WAN_IP" ]; then
					iptables -A PREROUTING -t nat -p $protocol --dport $fromport:$toport -d $PHY_WAN_IP -j DNAT --to-destination $ip
					iptables -A FORWARD         -d $ip -p $protocol --dport $fromport:$toport -j ACCEPT
				else
					iptables -A FORWARD -i $WAN -d $ip -p $protocol --dport $fromport:$toport -j ACCEPT
				fi
				# NAT Loopback
				iptables -t nat -I POSTROUTING -s $NET_IP/$LAN_SUBNET_MASK -p $protocol --dport $fromport:$toport -d $ip -j MASQUERADE
			done
			if [ "$isbcast" = 'Enabled' ]; then
				arp -s $ip FF:FF:FF:FF:FF:FF 2> /dev/null
			fi
			ARP_BCAST=`cat /proc/net/arp | grep $ip | grep 0x6 | grep FF:FF:FF:FF:FF:FF`
			if [ -n $ARP_BCAST ] && [ "$isbcast" = 'Disabled' ]; then
				arp -d $ip 2> /dev/null
			fi
		done
	fi

	if [ "$DMZ_HOST" != '0.0.0.0' ] && [ "$DMZ_ENABLED" = 'Enabled' ]; then
		if [ -n "$PHY_WAN_IP" ]; then
			if [ "$PPP_TYPE" = 'PPTP' ]; then
				iptables -A PREROUTING -t nat -i $PHY_WAN -p TCP --dport ! 1723 -d $PHY_WAN_IP -j DNAT --to-destination $DMZ_HOST
				iptables -A PREROUTING -t nat -i $PHY_WAN -p ! 47 -d $PHY_WAN_IP -j DNAT --to-destination $DMZ_HOST
			elif [ "$PPP_TYPE" = 'L2TP' ]; then
				iptables -A PREROUTING -t nat -i $PHY_WAN -p UDP --dport ! 1701 -d $PHY_WAN_IP -j DNAT --to-destination $DMZ_HOST
			elif [ $PPP_TYPE != 5 ]; then
				iptables -A PREROUTING -t nat -i $PHY_WAN -d $PHY_WAN_IP -j DNAT --to-destination $DMZ_HOST
			fi
			if [ $PPP_TYPE != 5 ]; then
				iptables -A FORWARD -i $PHY_WAN -d $DMZ_HOST -j ACCEPT
			fi
			if [ -n "$EXT_IP" ] && [ "$WAN" = "ppp0" ]; then
				if [ "$PPP_TYPE" = 'L2TP' ]; then
					iptables -A PREROUTING -t nat -i $PHY_WAN -p ! UDP -d $PHY_WAN_IP -j DNAT --to-destination $DMZ_HOST
				fi
				iptables -A PREROUTING -t nat -i $WAN -d $EXT_IP -j DNAT --to-destination $DMZ_HOST
				iptables -A FORWARD -i $WAN -d $DMZ_HOST -j ACCEPT
			fi
		else
			if [ -n "$EXT_IP" ]; then
				iptables -A PREROUTING -t nat -i $WAN -d $EXT_IP -j DNAT --to-destination $DMZ_HOST
			fi
			iptables  -A FORWARD -i $WAN -d $DMZ_HOST -j ACCEPT
		fi
	fi
}
set_forward
	
open_l2tp_port() {
	if [ "$PPP_TYPE" = 'L2TP' ]; then 
		iptables -A INPUT -i $BOARD_INTERFACE_WAN -p udp --dport 1701 -j ACCEPT
	fi
}
open_l2tp_port


set_management_access() {
	eval `flash \
FTP_ACCESS_ENABLED FTP_WAN_ACCESS_ENABLED FTP_WAN_ACCESS_LIST FTP_PORT \
TRNT_ENABLED TRNT_EXTERNAL_ACCESS_ENABLED TRNT_PORT TRNT_RPC_PORT \
WEB_WAN_ACCESS_ENABLED WEB_WAN_ACCESS_PORT WEB_WAN_ACCESS_LIST \
TR069_ENABLED TELNET_WAN_ACCESS_ENABLED TELNET_ACCESS_PORT TELNET_ACCESS_LIST \
PRINTSERVER_ENABLED PRINTSERVER_WAN_ACCESS_ENABLED`

	if [ "$FTP_ACCESS_ENABLED" = 'Enabled' -a "$FTP_WAN_ACCESS_ENABLED" = 'Enabled' ]; then
		# TODO FTP_WAN_ACCESS_LIST
		iptables -A INPUT -p tcp --dport $FTP_PORT -j ACCEPT
	fi

	if [ "$TRNT_ENABLED" = 'Enabled' ]; then
		iptables -A INPUT -p tcp --dport $TRNT_PORT -j ACCEPT
		if [ "$TRNT_EXTERNAL_ACCESS_ENABLED" = 'Enabled' ]; then
			iptables -A INPUT -p tcp --dport $TRNT_RPC_PORT -j ACCEPT
		fi
	fi

	if [ "$WEB_WAN_ACCESS_ENABLED" = 'Enabled' ];then
		if [ -z "$WEB_WAN_ACCESS_LIST" ]; then
			for iface in $PHY_WAN $WAN; do
				iptables -A INPUT -i $iface -m state --state NEW -m tcp -p tcp --dport $WEB_WAN_ACCESS_PORT -j ACCEPT
			done
		else
			for ipaddr in $WEB_WAN_ACCESS_LIST; do
				for iface in $PHY_WAN $WAN; do
					iptables -A INPUT -i $iface -m state --state NEW -m tcp -p tcp --dport $WEB_WAN_ACCESS_PORT -s $ipaddr -j ACCEPT
				done
			done
		fi
	fi

	if [ "$PRINTSERVER_ENABLED" = 'Enabled' -a "$PRINTSERVER_WAN_ACCESS_ENABLED" = 'Enabled' ];then
		iptables -A INPUT -p tcp --dport 9100 -j ACCEPT
	fi

	if [ "$TR069_ENABLED" = 'Enabled' ]; then
		for iface in $PHY_WAN $WAN; do
			iptables -A INPUT -i $iface -m state --state NEW -m tcp -p tcp --dport 8099 -j ACCEPT
		done
	fi

	if [ "$TELNET_WAN_ACCESS_ENABLED" = 'Enabled' ];then
		if [ -z "$TELNET_WAN_ACCESS_LIST" ]; then
			for iface in $PHY_WAN $WAN; do
				iptables -A INPUT -i $iface -m state --state NEW -m tcp -p tcp --dport $TELNET_ACCESS_PORT -j ACCEPT
			done
		else
			for ipaddr in $TELNET_WAN_ACCESS_LIST; do
				for iface in $PHY_WAN $WAN; do
					iptables -A INPUT -i $iface -m state --state NEW -m tcp -p tcp --dport $TELNET_ACCESS_PORT -s $ipaddr -j ACCEPT
				done
			done
		fi
	fi
}
set_management_access

set_ping_access() {
	eval `flash WAN_PING_ENABLED`
	if [ "$WAN_PING_ENABLED" = 'Disabled' ]; then
		for iface in $WAN $PHY_WAN; do
			iptables -A INPUT -p icmp --icmp-type echo-request -i $iface -j DROP
		done
	fi
	iptables -A INPUT -p icmp --icmp-type any -j ACCEPT
}
set_ping_access

set_clamp_mss() {
	# Setup proper MSS
	if [ "$OP_MODE" = 'WiMAX Router' ]; then
		iptables -t mangle -I FORWARD -p tcp -i $WAN --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
		iptables -t mangle -I FORWARD -p tcp -o $WAN --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
	fi
	if [ "$PPP_TYPE" != 'None' ]; then
		iptables -t mangle -I FORWARD -p tcp -i ppp0 --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
		iptables -t mangle -I FORWARD -p tcp -o ppp0 --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
	fi

	#if [ "$PPP_TYPE" = 'PPPoE' -o "$PPP_TYPE" = 'L2TP' -o $PPP_TYPE = 5 ]; then
	#	eval `flash PPP_MTU_SIZE`
	#	MSS=`expr $PPP_MTU_SIZE - 40`
	#	iptables -t nat -I POSTROUTING -o ppp0 -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss $MSS:1460 -j TCPMSS --set-mss $MSS
	#elif [ "$PPP_TYPE" = 'PPTP' ]; then
	#	eval `flash PPP_MTU_SIZE`
	#	MSS=`expr $PPP_MTU_SIZE - 48`
	#	iptables -t nat -I POSTROUTING -o ppp0 -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss $MSS:1460 -j TCPMSS --set-mss $MSS
	#fi
}
# set_clamp_mss

# Set TOS Priority
# Normal-Service = 0 (0x00)
# Minimize-Cost = 2 (0x02) - Very low
# Maximize-Reliability = 4 (0x04)
# Maximize-Throughput = 8 (0x08) - Low
# Minimize-Delay = 16 (0x10) - High
set_tos() {
	if [ "$WAN_AUTO_QOS_ENABLED" = 'Disabled' -o "$OP_MODE" = '3G Router' ]; then
		return
	fi

	# Set pfifo_fast
	for iface in $PHY_WAN $WAN $BRIDGE $BOARD_INTERFACE_ETH_BASE $BOARD_INTERFACE_LAN_WAN $BOARD_INTERFACE_ETH_WAN $BOARD_INTERFACE_WIRELESS_LAN; do
		ifconfig $iface txqueuelen 1000 2> /dev/null
	done

	# Set for Router
	iptables -A OUTPUT -t mangle -m owner --cmd-owner websv -j CONNMARK --set-mark 1
	iptables -A OUTPUT -t mangle -m owner --cmd-owner telnetd -j CONNMARK --set-mark 1
	if [ -e /bin/igmpproxy ]; then
		iptables -A OUTPUT -t mangle -m owner --cmd-owner igmpproxy -j CONNMARK --set-mark 1
	fi
	if [ -e /bin/dnrd ]; then
		iptables -A OUTPUT -t mangle -m owner --cmd-owner dnrd -j CONNMARK --set-mark 1
	elif [ -e /bin/dnsmasq ]; then
		iptables -A OUTPUT -t mangle -m owner --cmd-owner dnsmasq -j CONNMARK --set-mark 1
	fi
	iptables -A OUTPUT -t mangle -m owner --cmd-owner zyntp -j CONNMARK --set-mark 1

	if [ -e /bin/smbd ]; then
		iptables -A OUTPUT -t mangle -m owner --cmd-owner nmbd -j CONNMARK --set-mark 1
		iptables -A OUTPUT -t mangle -m owner --cmd-owner smbd -j CONNMARK --set-mark 3
	elif [ -e /bin/nqcs ]; then
		iptables -A OUTPUT -t mangle -m owner --cmd-owner nqnd -j CONNMARK --set-mark 1
		iptables -A OUTPUT -t mangle -m owner --cmd-owner nqcs -j CONNMARK --set-mark 3
	fi
	
	iptables -A OUTPUT -t mangle -m owner --cmd-owner vsftpd -j CONNMARK --set-mark 3
	iptables -A OUTPUT -t mangle -m owner --cmd-owner transmissiond -j CONNMARK --set-mark 5
	iptables -A INPUT  -t mangle -m connmark --mark 1 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -m connmark --mark 1 -j TOS --set-tos Minimize-Delay
	iptables -A INPUT  -t mangle -m connmark --mark 3 -j TOS --set-tos Maximize-Throughput
	iptables -A OUTPUT -t mangle -m connmark --mark 3 -j TOS --set-tos Maximize-Throughput

	# P2P
	iptables -t mangle -A PREROUTING -p tcp -j CONNMARK --restore-mark
	iptables -t mangle -A PREROUTING -p tcp -m mark ! --mark 0 -j ACCEPT
	iptables -t mangle -A PREROUTING -p tcp -m ipp2p --ipp2p -j MARK --set-mark 5
	iptables -t mangle -A PREROUTING -p tcp -m mark --mark 5 -j CONNMARK --save-mark
	iptables -t mangle -A INPUT -m connmark --mark 5 -j TOS --set-tos Minimize-Cost
	iptables -t mangle -A OUTPUT -m connmark --mark 5 -j TOS --set-tos Minimize-Cost
	iptables -t mangle -A POSTROUTING -m connmark --mark 5 -j TOS --set-tos Minimize-Cost

	# IN
	iptables -A PREROUTING -t mangle -p icmp -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p igmp -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 53 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p udp --sport 53 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 23 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 22 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 25 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 80 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 110 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 113 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 143 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 443 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 8080 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p udp --sport 5060 -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -p tcp --sport 21 -j TOS --set-tos Maximize-Throughput
	iptables -A PREROUTING -t mangle -p tcp --sport 20 -j TOS --set-tos Maximize-Throughput

	# OUT
	iptables -A OUTPUT -t mangle -p icmp -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p igmp -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 53 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p udp --dport 53 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 23 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 22 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 25 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 80 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 110 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 113 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 143 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 443 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 8080 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p udp --dport 5060 -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -p tcp --dport 21 -j TOS --set-tos Maximize-Throughput
	iptables -A OUTPUT -t mangle -p tcp --dport 20 -j TOS --set-tos Maximize-Throughput

	# Auto fix
	iptables -A PREROUTING -t mangle -m connbytes --connbytes 0:51200 --connbytes-dir both --connbytes-mode bytes -j TOS --set-tos Minimize-Delay
	iptables -A OUTPUT -t mangle -m connbytes --connbytes 0:51200 --connbytes-dir both --connbytes-mode bytes -j TOS --set-tos Minimize-Delay
	iptables -A PREROUTING -t mangle -m connbytes --connbytes 512000: --connbytes-dir both --connbytes-mode bytes -j TOS --set-tos Maximize-Throughput
	iptables -A OUTPUT -t mangle -m connbytes --connbytes 512000: --connbytes-dir both --connbytes-mode bytes -j TOS --set-tos Maximize-Throughput
}
set_tos

# TTL inc on 1 
set_ttl_inc() { 
	if [ "$WAN_TTL_INC_ENABLED" = 'Enabled' -a "$OP_MODE" != '3G Router' ]; then
		iptables -t mangle -I PREROUTING -j TTL --ttl-inc 1 
		iptables -t mangle -I POSTROUTING -j TTL --ttl-inc 1 
	fi
}
set_ttl_inc

set_stb_fwd() { 
	if [ $DHCP_O60_TBL_NUM != "0" ]; then
		iptables -t nat -N STB
		iptables -t nat -A PREROUTING -i $WAN -j STB
		iptables -N STB
		iptables -A FORWARD -i $WAN -j STB
	fi
}
set_stb_fwd

set_clamp_mss

FWL=/var/dhcpd_ven/firewall.sh

if [ -x $FWL ]; then
	$FWL 2> /dev/null
fi

FWL=/media/DISK_A1/system/bin/ext_firewall.sh

if [ -x $FWL ]; then
	$FWL 2> /dev/null
fi
