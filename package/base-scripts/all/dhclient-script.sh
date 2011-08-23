#!/bin/sh

if [ "$1" != 'bound' ]; then
	exit 0
fi

CHANGE_IP=0

check_change_ip() {
	SAVE_IP="/var/udhcpc/saveip.$interface"
	if [ -f $SAVE_IP ]; then
		CHECK_IP=`cat $SAVE_IP`
		if [ "$ip" != "$CHECK_IP" ]; then
			echo -n $ip > $SAVE_IP
			CHANGE_IP=1
		else
			CHANGE_IP=0
		fi
	else
		echo -n $ip > $SAVE_IP
		CHANGE_IP=1
	fi
}

create_resolv_conf() {
	RESOLV_CONF="/var/udhcpc/resolv.conf"

	echo -n > $RESOLV_CONF
	[ -n "$domain" ] && echo domain $domain >> $RESOLV_CONF

	for i in $dns; do
		echo nameserver $i >> $RESOLV_CONF
	done
}

setup_default_routes() {
	if [ "$router" ]; then
		for i in $router ; do
			route del default dev $interface 2> /dev/null
			route add default gw $i dev $interface 2> /dev/null || route add default dev $interface 2> /dev/null
		done
	fi
}

setup_static_routes() {
	# DHCP CSR(Classless Static Route) feature
	if [ "$cl_routes" ]; then
		echo "Adding Classless Static Routes..."
		for r in $cl_routes; do 
			net=`echo $r | cut -f1 -d '/'`
			mask=`echo $r | cut -f2 -d '/'`
			gw=`echo $r | cut -f3 -d '/'`
			route add -net $net netmask $mask gw $gw 2> /dev/null
		done
	fi

	# DHCP CSR(Classless Static Route) feature
	if [ "$mcl_routes" ]; then
		echo "Adding Microsoft Classless Static Routes..."
		for r in $mcl_routes; do 
			net=`echo $r | cut -f1 -d '/'`
			mask=`echo $r | cut -f2 -d '/'`
			gw=`echo $r | cut -f3 -d '/'`
			route add -net $net netmask $mask gw $gw 2> /dev/null
		done
	fi

	# DHCP option 33 Static routing feature
	if [ "$sroutes" ]; then
		echo "Adding Static Routes..."
		for r in $sroutes; do 
			ip=`echo $r | cut -f1 -d '/'`
			gw=`echo $r | cut -f2 -d '/'`
			route add $ip gw $gw 2> /dev/null
		done
	fi
	route.sh
}

. /bin/iface-names.sh

if [ "$1" = 'deconfig' ]; then
	ifconfig $2 0.0.0.0 2> /dev/null
	exit 0
fi

eval `flash OP_MODE PPP_TYPE`

if [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
	PPP_TYPE='None'
fi

check_change_ip

if [ $CHANGE_IP = 0 ]; then
	create_resolv_conf
	setup_static_routes
	exit 0
else
	if [ "$PPP_TYPE" != 'None' ]; then
		WAN_PPP=`ifconfig | grep ppp0 | cut -f1 -d" "`
		if [ "$WAN_PPP" = "ppp0" ]; then
			ppp.sh disconnect
		fi
	else
		ledctl 2
	fi
fi

[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

/sbin/ifconfig $interface $ip $BROADCAST $NETMASK 2> /dev/null

create_resolv_conf

setup_default_routes
setup_static_routes
dns.sh

killall firewall.sh 2> /dev/null
firewall.sh

killall ddns.sh 2> /dev/null
ddns.sh
upnp.sh
igmpproxy.sh
zyut udpreset &

if [ "$PPP_TYPE" != 'None' ]; then
	ppp.sh start
else
	ledctl 1
fi
