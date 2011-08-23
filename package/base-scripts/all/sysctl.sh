#!/bin/sh

echo "1" > /proc/sys/net/ipv4/ip_forward
echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout
echo "120" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "1200" > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established
echo "60" > /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout
echo "1" > /proc/sys/net/ipv4/tcp_syncookies

TSIZE=10240

# Location depends on the kernel version
if [ -f /proc/sys/net/ipv4/ip_conntrack_max ]; then
	echo $TSIZE > /proc/sys/net/ipv4/ip_conntrack_max
elif [ -f /proc/sys/net/ipv4/netfilter/ip_conntrack_max ]; then
	echo $TSIZE > /proc/sys/net/ipv4/netfilter/ip_conntrack_max
fi
