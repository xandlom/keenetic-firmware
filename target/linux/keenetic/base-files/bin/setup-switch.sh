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

	switch vlan set 0 1 1111011
	switch vlan set 1 2 0000101
	switch pvid set 1 1 1 1 2 1 1
}

setup_iptv_direct() {
	switch vlanen  set 0000001
	switch vlantag set 1111110
	
	case $IPTV_PORT in
	0)
		switch vlan set 0 1 1110011
		switch vlan set 1 2 0001101
		switch pvid set 1 1 1 2 2 1 1
	;;
	1)
		switch vlan set 0 1 1101011
		switch vlan set 1 2 0010101
		switch pvid set 1 1 2 1 2 1 1
	;;
	2)
		switch vlan set 0 1 1011011
		switch vlan set 1 2 0100101
		switch pvid set 1 2 1 1 2 1 1
	;;
	3)
		switch vlan set 0 1 0111011
		switch vlan set 1 2 1000101
		switch pvid set 2 1 1 1 2 1 1
	;;
	4)
		switch vlan set 0 1 0011011
		switch vlan set 1 2 1100101
		switch pvid set 2 2 1 1 2 1 1
	;;
	esac
}

setup_voip_vlan() {

	eval `flash VOIP_PORT_ENABLED`

	if [ "$VOIP_PORT_ENABLED" = 'Disabled' ]; then
		return
	fi

	eval `flash %VOIP_PORT VOIP_VLAN_TAG`
	RUN_VOIP=0
	IDX=3
	if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
		IDX=4
	fi
	
	case $VOIP_PORT in
	0)
		case $IPTV_PORT in
		1)
		    PORT_MAP=1100011
		    P2=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		2)
		    PORT_MAP=1010011
		    P1=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		3)
		    PORT_MAP=0110011
		    P0=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		4)
		    PORT_MAP=0010011
		    P0=$IPTV_VLAN_TV_TAG
		    P1=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		esac
		if [ $RUN_VOIP = 1 ]; then
		    P3=$VOIP_VLAN_TAG
		    switch vlan set $IDX $VOIP_VLAN_TAG 0001100
		fi
	;;
	1)
		case $IPTV_PORT in
		0)
		    PORT_MAP=1100011
		    P3=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		2)
		    PORT_MAP=1001011
		    P1=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		3)
		    PORT_MAP=0101011
		    P0=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		4)
		    PORT_MAP=0001011
		    P0=$IPTV_VLAN_TV_TAG
		    P1=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		esac
		if [ $RUN_VOIP = 1 ]; then
		    P2=$VOIP_VLAN_TAG
		    switch vlan set $IDX $VOIP_VLAN_TAG 0010100
		fi
	;;
	2)
		case $IPTV_PORT in
		0)
		    PORT_MAP=1010011
		    P3=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		1)
		    PORT_MAP=1001011
		    P2=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		3)
		    PORT_MAP=0011011
		    P0=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		esac
		if [ $RUN_VOIP = 1 ]; then
		    P1=$VOIP_VLAN_TAG
		    switch vlan set $IDX $VOIP_VLAN_TAG 0100100
		fi
	;;
	3)
		case $IPTV_PORT in
		0)
		    PORT_MAP=0110011
		    P3=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		1)
		    PORT_MAP=0101011
		    P2=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		2)
		    PORT_MAP=0011011
		    P1=$IPTV_VLAN_TV_TAG
		    RUN_VOIP=1
		;;
		esac
		if [ $RUN_VOIP = 1 ]; then
		    P0=$VOIP_VLAN_TAG
		    switch vlan set $IDX $VOIP_VLAN_TAG 1000100
		fi
	;;
	esac
}

setup_iptv_vlan() {

	eval `flash IPTV_VLAN_TV_TAG IPTV_VLAN_TV2_TAG IPTV_VLAN_WAN_TAG IPTV_VLAN_TV2_ENABLED`

	switch vlanen  set 0000101 # Enable vlan tracking
	switch vlantag set 1111010 # Disable tag removal
	# set LLLLWLL
	P0=$IPTV_VLAN_LAN_TAG
	P1=$IPTV_VLAN_LAN_TAG
	P2=$IPTV_VLAN_LAN_TAG
	P3=$IPTV_VLAN_LAN_TAG
	P4=$IPTV_VLAN_WAN_TAG
	P5=$IPTV_VLAN_LAN_TAG
	P6=$IPTV_VLAN_LAN_TAG
	RUN_PVID=0

	case $IPTV_PORT in
	0)
		PORT_MAP=1110011
		P3=$IPTV_VLAN_TV_TAG
		setup_voip_vlan
		switch vlan set 0 $IPTV_VLAN_LAN_TAG $PORT_MAP
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 0000101
		switch vlan set 2 $IPTV_VLAN_TV_TAG  0001101
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 0001101
		fi
		RUN_PVID=1
	;;
	1)
		PORT_MAP=1101011
		P2=$IPTV_VLAN_TV_TAG
		setup_voip_vlan
		switch vlan set 0 $IPTV_VLAN_LAN_TAG $PORT_MAP
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 0000101
		switch vlan set 2 $IPTV_VLAN_TV_TAG  0010101
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 0010101
		fi
		RUN_PVID=1
	;;
	2)
		PORT_MAP=1011011
		P1=$IPTV_VLAN_TV_TAG
		setup_voip_vlan
		switch vlan set 0 $IPTV_VLAN_LAN_TAG $PORT_MAP
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 0000101
		switch vlan set 2 $IPTV_VLAN_TV_TAG  0100101
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 0100101
		fi
		RUN_PVID=1
	;;
	3)
		PORT_MAP=0111011
		P0=$IPTV_VLAN_TV_TAG
		setup_voip_vlan
		switch vlan set 0 $IPTV_VLAN_LAN_TAG $PORT_MAP
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 0000101
		switch vlan set 2 $IPTV_VLAN_TV_TAG  1000101
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 1000101
		fi
		RUN_PVID=1
	;;
	4)
		PORT_MAP=0011011
		P0=$IPTV_VLAN_TV_TAG
		P1=$IPTV_VLAN_TV_TAG
		setup_voip_vlan
		switch vlan set 0 $IPTV_VLAN_LAN_TAG $PORT_MAP
		switch vlan set 1 $IPTV_VLAN_WAN_TAG 0000101
		switch vlan set 2 $IPTV_VLAN_TV_TAG  1100101
		if [ "$IPTV_VLAN_TV2_ENABLED" = 'Enabled' ]; then
			switch vlan set 3 $IPTV_VLAN_TV2_TAG 1100101
		fi
		RUN_PVID=1
	;;
	esac
	if [ $RUN_PVID = 1 ]; then
		switch pvid set $P0 $P1 $P2 $P3 $P4 $P5 $P6
	fi
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
