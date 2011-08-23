#!/bin/sh

. /bin/iface-names.sh

CONF_FILE=/var/udhcpd.conf
LEASE_FILE=/var/lib/misc/udhcpd.leases
NOTIFY_FILE=/bin/dhcpd_vendor.sh

eval `flash LAN_DHCP_MODE`
if [ "$LAN_DHCP_MODE" != 'Server' ]; then
	exit 0
fi

eval `flash DHCP_O60_TBL_NUM`

echo "interface $BOARD_INTERFACE_LAN" > $CONF_FILE

eval `flash OP_MODE LAN_IP_ADDR LAN_DEFAULT_GATEWAY LAN_DHCP_POOL_START LAN_DHCP_POOL_END LAN_SUBNET_MASK`
echo "start $LAN_DHCP_POOL_START" >> $CONF_FILE
echo "end $LAN_DHCP_POOL_END" >> $CONF_FILE
echo "opt lease 864000" >> $CONF_FILE
echo "opt subnet $LAN_SUBNET_MASK" >> $CONF_FILE

if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' ]; then
	if [ -n "$LAN_DEFAULT_GATEWAY" ] && [ "$LAN_DEFAULT_GATEWAY" != "0.0.0.0" ]; then
		echo "opt router $LAN_DEFAULT_GATEWAY"  >> $CONF_FILE
	fi
else	
	echo "opt router $LAN_IP_ADDR"  >> $CONF_FILE
fi

#eval `flash WAN_DNS_MODE WAN_DNS1 WAN_DNS2 WAN_DNS3`
#if [ "$WAN_DNS_MODE" = 'Enabled' -a "$OP_MODE" != 'WiFi Access Point' ]; then
	echo "opt dns $LAN_IP_ADDR" >> $CONF_FILE
#else
#	if [ "$WAN_DNS1" != "0.0.0.0" ]; then
#		echo "opt dns $WAN_DNS1" >> $CONF_FILE
#	fi
#	if [ "$WAN_DNS2" != "0.0.0.0" ]; then
#		echo "opt dns $WAN_DNS2" >> $CONF_FILE
#	fi
#	if [ "$WAN_DNS3" != "0.0.0.0" ]; then
#		echo "opt dns $WAN_DNS3" >> $CONF_FILE
#	fi
#fi

#if [ "`cat $CONF_FILE | grep dns`" = "" ] && [ "$OP_MODE" != 'WiFi Access Point' ]; then
#	echo "opt dns $LAN_IP_ADDR"  >> $CONF_FILE
#fi

flash STATICLEASE_TBL | while read line; do
	eval $line
	echo "static_lease $mac $ip" >> $CONF_FILE
done

if [ ! -f "$LEASE_FILE" ]; then
	echo "" > $LEASE_FILE
fi

if [ ! -d "/var/dhcpd_ven" ]; then
	mkdir -p /var/dhcpd_ven
else
	rm -fR /var/dhcpd_ven
	mkdir -p /var/dhcpd_ven
fi

iptables -t nat -F STB 1>/dev/null 2>/dev/null
iptables -F STB 1>/dev/null 2>/dev/null

if [ $DHCP_O60_TBL_NUM != "0" ]; then
	echo "notify_file $NOTIFY_FILE" >> $CONF_FILE
fi

flash DHCP_O60_TBL | while read line; do
	eval $line
	ven_conf=/var/dhcpd_ven/$((idx+1)).conf

	echo "vendor_class \"$vci\" $ven_conf" >> $CONF_FILE

	if [ "$vsi" != "" ]; then
		echo -n "opt vendorinfo" >> $ven_conf
		while [ ! ${#vsi} -eq 0 ];
		do
			echo -n " 0x"`echo $vsi | head -c 2` >> $ven_conf
			vsi=`echo $vsi | tail -c +3`
		done
		echo "" >> $ven_conf
	fi

	if [ "$dns" != "" ]; then
		echo "opt dns $dns" >> $ven_conf
	fi

	if [ "$ntp" != "" ]; then
		echo "opt ntpsrv $ntp" >> $ven_conf
	fi
done

udhcpd -S $CONF_FILE
