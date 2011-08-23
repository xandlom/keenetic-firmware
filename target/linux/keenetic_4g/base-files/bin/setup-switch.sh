#!/bin/sh

eval `flash OP_MODE IPTV_MODE %IPTV_PORT`

switch_vlan_reset() {
	SEQ="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"

	for i in $SEQ; do
		if [ "$IPTV_MODE" = '802.1q' ]; then
			switch vlan set $i $((i+1)) 0000000
		else
			switch vlan set $i $((i+1)) 1111111
		fi
	done
	switch pvid set 1 1 1 1 1 1 1
}

setup_switch_switch() {
	switch vlanen  set 0000001
	switch vlantag set 1111110

	switch vlan set 0 1 1111111
	switch vlan set 1 2 1111111
	switch pvid set 1 1 1 1 1 1 1
}

setup_switch_router() {
	switch vlanen  set 0000001
	switch vlantag set 1111110

	switch vlan set 0 1 0111111
	switch vlan set 1 2 1000001
	switch pvid set 2 1 1 1 1 1 1
}

setup_iptv_direct() {
	switch vlanen  set 0000001
	switch vlantag set 1111110
	
	case $IPTV_PORT in
	0)
		switch vlan set 0 1 0101111
		switch vlan set 1 2 1010001
		switch pvid set 2 1 2 1 1 1 1
	;;
	1)
		switch vlan set 0 1 0011111
		switch vlan set 1 2 1100001
		switch pvid set 2 2 1 1 1 1 1
	;;
	esac
}

setup_iptv_vlan() {
	eval `flash IPTV_VLAN_TV_TAG IPTV_VLAN_TV2_TAG IPTV_VLAN_WAN_TAG IPTV_VLAN_TV2_ENABLED`

	switch vlanen  set 1000001 # Enable vlan tracking
	switch vlantag set 0111110 # Disable tag removal

	case $IPTV_PORT in
	0)
		switch vlan set 0 $IPTV_VLAN_LAN_TAG 0101111
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 1000001
		switch vlan set 2 $IPTV_VLAN_TV_TAG  1010001
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 1010001
		fi
		switch pvid set $IPTV_VLAN_WAN_TAG $IPTV_VLAN_LAN_TAG \
			$IPTV_VLAN_TV_TAG $IPTV_VLAN_LAN_TAG \
			$IPTV_VLAN_LAN_TAG $IPTV_VLAN_LAN_TAG \
			$IPTV_VLAN_LAN_TAG
	;;
	1)
		switch vlan set 0 $IPTV_VLAN_LAN_TAG 0011111
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 1000001
		switch vlan set 2 $IPTV_VLAN_TV_TAG  1100001
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 1100001
		fi
		switch pvid set $IPTV_VLAN_WAN_TAG $IPTV_VLAN_TV_TAG \
			$IPTV_VLAN_LAN_TAG $IPTV_VLAN_LAN_TAG \
			$IPTV_VLAN_LAN_TAG $IPTV_VLAN_LAN_TAG \
			$IPTV_VLAN_LAN_TAG
	;;
	esac
}

stop() {
	devices=`cat /proc/net/vlan/config | grep eth | cut -d' ' -f 1`
	for d in $devices; do
		vconfig rem $d 2> /dev/null
	done
}

start() {
	switch_vlan_reset
	ifconfig eth2 up 2> /dev/null

	if [ "$OP_MODE" != 'Ethernet Router' ]; then
		setup_switch_switch
		vconfig add eth2 1 2> /dev/null
		return
	fi

	IPTV_VLAN_LAN_TAG=1
	IPTV_VLAN_WAN_TAG=2
	# FIXME: set port registers properly
	if [ "$IPTV_MODE" = 'Disabled' ]; then
		setup_switch_router
	elif [ "$IPTV_MODE" = 'Direct' ] ; then
		setup_iptv_direct
	elif [ "$IPTV_MODE" = '802.1q' ]; then
		setup_iptv_vlan
	fi

	vconfig add eth2 $IPTV_VLAN_LAN_TAG 2> /dev/null
	vconfig add eth2 $IPTV_VLAN_WAN_TAG 2> /dev/null
	# Add multi-VLAN support
	if [ "$OP_MODE" = 'Ethernet Router' -a "$IPTV_MODE" = '802.1q' ]; then
		vconfig add eth2 $IPTV_VLAN_TV_TAG 2> /dev/null
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			vconfig add eth2 $IPTV_VLAN_TV2_TAG 2> /dev/null
		fi
	fi
}

VLAN_CONFIGURED=`cat /proc/net/vlan/config | grep eth `
if [ -n "$VLAN_CONFIGURED" ]; then
	stop
fi

start
