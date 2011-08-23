#!/bin/sh

DHCPCOLDIP=/tmp/ddns.dhcp.oldip
OLDIP=/tmp/ddns.oldip
LINKFILE=/etc/ppp/link
RESULTFILE=/var/run/ddns.status

. /bin/iface-names.sh

eval `flash DDNS_ENABLED`

if [ "$DDNS_ENABLED" = 'Disabled' ]; then
	exit
fi

eval `flash WAN_IP_ADDRESS_MODE PPP_TYPE OP_MODE DDNS_TYPE DDNS_NAME_TYPE DDNS_DOMAIN_NAME @:DDNS_USER @:DDNS_PASSWORD`

if [ "$DDNS_TYPE" = 'DynDNS' ]; then
	SERVICE=dyndns
elif [ "$DDNS_TYPE" = 'TZO' ]; then
	SERVICE=tzo
else
	if [ "$DDNS_NAME_TYPE" = 'Domain' ]; then
		SERVICE=noip
	else
		SERVICE="noip -g"
	fi
fi

renew=1
num=0

echo "updating" > $RESULTFILE

# fix for USB modems
if [ "$OP_MODE" = '3G Router' ] ; then
	PPP_TYPE=5
elif [ "$OP_MODE" = 'WiFi Access Point' -o "$OP_MODE" = 'Wireless Bridge' -o "$OP_MODE" = 'WiMAX Router' ]; then
	PPP_TYPE='None'
fi

{
	while [ true ]; do
			num=`expr $num + 1`
			if [ $num -ge 8640 ]; then
				num=0
				renew=1
			fi

			sleep 10

			if [ "$WAN_IP_ADDRESS_MODE" = 'Static' ] && [ "$PPP_TYPE" = 'None' ] ; then
				if [ $renew != 1 ]; then
					continue
				fi
			elif [ "$WAN_IP_ADDRESS_MODE" = 'Auto' ] && [ "$PPP_TYPE" = 'None' ] ; then

				s1=`ifconfig $BOARD_INTERFACE_WAN 2> /dev/null| grep "inet addr"`
				s2=`echo $s1 | cut -f2 -d:`
				s3=`echo $s2 | cut -f1 -d " "`
				if [ -z $s3 ]; then
					continue
				fi
				if [ ! -f $DHCPCOLDIP ]; then
					echo "0.0.0.0" > $DHCPCOLDIP
				fi
				str=`cat $DHCPCOLDIP`
				if [ $renew != 1 ] && [ $s3 = $str ]; then
					continue
				fi
			elif [ "$PPP_TYPE" != 'None' ]; then
				if [ ! -f $LINKFILE ]; then
					continue
				fi

				s1=`ifconfig ppp0 2> /dev/null| grep "inet addr"`
				s2=`echo $s1 | cut -f2 -d:`
				s3=`echo $s2 | cut -f1 -d " "`
				if [ ! -f $OLDIP ]; then
					echo "0.0.0.0" > $OLDIP
				fi
				str=`cat $OLDIP`
				if [ $renew != 1 ] && [ $s3 = $str ]; then
					continue
				fi
			fi

			updatedd -- $SERVICE $DDNS_USER:$DDNS_PASSWORD $DDNS_DOMAIN_NAME > $RESULTFILE 2>&1
			ret=`echo $?`

			if [ "$PPP_TYPE" != 'None' ]; then
				if [ $ret = 0 ]; then
					echo $s3 > $OLDIP
					num=0
					renew=0
				fi
			else
				if [ $ret = 0 ]; then
					echo $s3 > $DHCPCOLDIP
					num=0
					renew=0
				fi
			fi
	done
} &
