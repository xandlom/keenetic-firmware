#!/bin/sh

# $1 - action (release or ack)
# $2 - mac (00:11:22:33:44:55)
# $3 - ip (192.168.0.34)
# $4 - lease time
# $5 - static_lease (0 or 1)
# $6 - vendorclass (if any)

START_PORT=65501
STB_IDX_FILE="/var/dhcpd_ven/stb_last_idx"
STB_FW="/var/dhcpd_ven/firewall.sh"
STB_IP=$3

if [ ! -f $STB_IDX_FILE ]; then
	STB_IDX=0
else
	STB_IDX=`cat $STB_IDX_FILE`
fi

if [ "$1" = "ack" ] && [ "$5" = "0" ] && [ "$6" != "" ]; then
	MAP_PORT=`expr $START_PORT + $STB_IDX`
	STB_IDX=`expr $STB_IDX + 1`

	echo $STB_IDX > $STB_IDX_FILE

	if [ ! -f $STB_FW ]; then
		echo "#!/bin/sh" > $STB_FW
		chmod 755 $STB_FW
	fi

	echo "iptables -t nat -A STB -p tcp --dport $MAP_PORT -j DNAT --to-destination $STB_IP:22" >> $STB_FW
	echo "iptables -A STB -d $STB_IP -p tcp --dport 22 -j ACCEPT" >> $STB_FW

	iptables -t nat -A STB -p tcp --dport $MAP_PORT -j DNAT --to-destination $STB_IP:22
	iptables -A STB -d $STB_IP -p tcp --dport 22 -j ACCEPT
fi
