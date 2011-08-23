#!/bin/sh

cmd=$1

PPPDFILE=/var/tmp/_pppd_sh
KILL=/var/tmp/ppp_kill
LINKFILE=/etc/ppp/link

STATUSFILE=/var/tmp/pppstatus
RESULTFILE=/var/tmp/pppresult
CHAINFILE=/var/tmp/pppchain

OPTIONS=/etc/ppp/options
PAPFILE=/etc/ppp/pap-secrets
CHAPFILE=/etc/ppp/chap-secrets
L2TPFILE=/etc/ppp/l2tp-secrets
CONNECTFILE=/etc/ppp/connectfile
PPPFAILS=/var/tmp/pppfails

WAN_STATUS=/var/tmp/wan_iface

PPTPNUMFILE=/var/pptpnum

CHAT=/etc/ppp/modem.chat
MODEM_AT_SETUP=/var/usbstatus/modem_at_setup
DEVTTYFILE=/var/tmp/devtty
DEVTTY=""

echo_options() {
	for op; do echo $op; done
}

is_iface_up() {
	eval `flash WAN_IP_ADDRESS_MODE`
	if [ `ifconfig | grep $1 | wc -l` != 0 ]; then
		if [ "$WAN_IP_ADDRESS_MODE" = 'No IP' ]; then
			return 0
		elif [ `ifconfig $1 2> /dev/null | grep "inet addr:" | wc -l` != 0 ]; then
			return 0
		fi
	fi
	return 1
}


get_server_route() {
	# PPP_SERVER_IP=`(nslookup $PPP_SERVER || echo "Address 1: no_ip") | grep "Address 1:" | tail -n 1 | cut -d" " -f 3`
	PPP_SERVER_IP=`zyut nslookup $PPP_SERVER`
	if [ "$PPP_SERVER_IP" = "no_ip" ]; then 
		echo "No responce" > $STATUSFILE
		echo 3 > $RESULTFILE
		echo "2" >> $CHAINFILE
		echo "3" >> $CHAINFILE
		return 1
	fi

	gate=`route -n | { while read net gw mask flags metric ref use iface; do [ $net = "0.0.0.0" -a $flags = "UG" ] && echo $gw; done ; } | tail -n 1`
	[ "$gate" = "" ] && return 1
	if [ -n "$PHY_WAN_IP" ] && [ -n "$PHY_WAN_MASK" ]; then
		zyut in_net $PHY_WAN_IP $PHY_WAN_MASK $PPP_SERVER_IP
		[ $? = 0 ] && return 1
	fi
	return 0
}


add_server_route() {
	get_server_route && {
		route add -host $PPP_SERVER_IP gw $gate 2> /dev/null
		PPP_SERVER=$PPP_SERVER_IP
		return 0
	}
	[ "$PPP_SERVER_IP" = "no_ip" ] && return 1
	return 0
}


del_server_route() {
	get_server_route && {
		route del -host $PPP_SERVER_IP gw $gate 2> /dev/null
		return 0
	}
	return 1
}


# Fills auth and mppe options. Called from l2tp, pptp and pppoe, creates handler scripts
ppp_options() {
	eval `flash PPP_AUTH_TYPE PPP_MPPE_LEVEL PPP_MTU_SIZE DEBUG_PPPD`

	[ "$DEBUG_PPPD" = 'Enabled' ] &&
		echo debug >> $OPTIONS

	echo_options noauth nobsdcomp nopcomp noaccomp nodeflate \
	             usepeerdns defaultroute replacedefaultroute "mtu $PPP_MTU_SIZE" "mru $PPP_MTU_SIZE" >> $OPTIONS

	case $PPP_AUTH_TYPE in
	Auto)         ;;
	PAP)          echo_options refuse-chap refuse-mschap refuse-mschap-v2 >> $OPTIONS ;;
	CHAP)         echo_options refuse-pap refuse-mschap refuse-mschap-v2 >> $OPTIONS ;;
	'MS-CHAP v1') echo_options refuse-pap refuse-chap >> $OPTIONS ;;
	'MS-CHAP v2') echo_options refuse-pap refuse-chap refuse-mschap >> $OPTIONS ;;
	esac

	echo "refuse-eap" >> $OPTIONS

	if [ "$PPP_AUTH_TYPE" = 'PAP' -o "$PPP_AUTH_TYPE" = 'CHAP' ]; then
		echo_options noccp nomppe >> $OPTIONS
	else
		case $PPP_MPPE_LEVEL in
		'None')    echo_options "noccp" "nomppe" >> $OPTIONS ;;
		'40-bit')  echo_options "mppe required,no56,no128,stateless" >> $OPTIONS ;;
		'56-bit')  echo_options "mppe required,no40,no128,stateless" >> $OPTIONS ;;
		'128-bit') echo_options "mppe required,no40,no56,stateless" >> $OPTIONS ;;
		'Auto')    echo_options "mppe required,stateless" >> $OPTIONS ;;
		esac
	fi

	ln -sf /bin/ppp-up.sh /etc/ppp/ip-up 
	ln -sf /bin/ppp-down.sh /etc/ppp/ip-down 
}


user_pass_options() {
	if [ -n "$PPP_USER_NAME" ] ; then
		echo "name $PPP_USER_NAME" > $OPTIONS
		echo "#################################################" > $PAPFILE
		echo "\"$PPP_USER_NAME\"	*	\"$PPP_PASSWORD\"  *" >> $PAPFILE
		echo "#################################################" > $CHAPFILE
		echo "\"$PPP_USER_NAME\"	*	\"$PPP_PASSWORD\"  *" >> $CHAPFILE
		echo "#################################################" > $L2TPFILE
		echo "\"$PPP_USER_NAME\"	*	\"$PPP_PASSWORD\"  *" >> $L2TPFILE
	else
		echo "" > $OPTIONS
	fi
}


pppoe_build_options() {
	user_pass_options

	if [ "$PPP_IP_AUTO" = 'Static' ]; then
		echo "$PPP_IP_ADDR:$PPP_REMOTE_IP_ADDR
		netmask $PPP_REMOTE_SUBNET_MASK" >> $OPTIONS
	fi

	eval `flash PPP_SERVICE_NAME PPP_AC_NAME`

	[ -n "$PPP_SERVICE_NAME" ] &&
		PPP_SERVICE_NAME="rp_pppoe_service '$PPP_SERVICE_NAME'"

	[ -n "$PPP_AC_NAME" ] &&
		PPP_AC_NAME="rp_pppoe_ac '$PPP_AC_NAME'"

	echo "plugin \"rp-pppoe.so\" $PPP_SERVICE_NAME $PPP_AC_NAME $BOARD_INTERFACE_WAN" >> $OPTIONS

	echo_options noipdefault ipcp-accept-remote ipcp-accept-local \
	            "lcp-echo-interval 20" "lcp-echo-failure 15" >> $OPTIONS

	# Fill auth and mppe options
	ppp_options
}


reinit_build_options() {
	return 0
	[ "$PPP_REINIT_ENABLED" = "Enabled" ] && \
		echo_options "persist" "maxfail 20" >> $OPTIONS
}


reinit_wan() {
	[ "`flash cat PPP_REINIT_ENABLED`" != "Enabled" ] && return

	if [ `cat $RESULTFILE 2>/dev/null || echo 0` = "3" ]; then
		count=$((`cat $PPPFAILS 2>/dev/null || echo 0`+1))
		echo $count >$PPPFAILS
		[ $count -ge 5 ] && {
			rm -f $PPPFAILS
			ppp-reinit.sh
		}
	else
		rm -f $PPPFAILS 2>/dev/null
	fi
}


pptp_build_options() {
	user_pass_options

	if [ "$PPP_IP_AUTO" = 'Static' ]; then
		echo "$PPP_IP_ADDR":"$PPP_REMOTE_IP_ADDR" >> $OPTIONS
	fi

	reinit_build_options
	echo_options "lcp-echo-interval 60" "lcp-echo-failure 5" \
	             "plugin \"pptp.so\"" "pptp_server $PPP_SERVER" >> $OPTIONS

	# Fill auth and mppe options
	ppp_options
}


l2tp_build_options() {
	user_pass_options

	if [ "$PPP_IP_AUTO" = 'Static' ]; then
		echo "$PPP_IP_ADDR":"$PPP_REMOTE_IP_ADDR" >> $OPTIONS
	fi

	reinit_build_options
	echo_options "lcp-echo-interval 60" "lcp-echo-failure 5" \
	             "plugin \"pppol2tp.so\"" "l2tp_lns $PPP_SERVER" >> $OPTIONS

	# Fill auth and mppe options
	ppp_options
}


modem_setup() {
	eval `flash MODEM_PHONE_NUMBER MODEM_APN MODEM_AUTH_TYPE MODEM_MTU_SIZE @MODEM_USERNAME @MODEM_PASSWORD \
MODEM_INIT_ATCMDS_ENABLED @MODEM_INIT_ATCMDS1 @MODEM_INIT_ATCMDS2 @MODEM_INIT_ATCMDS3`

	if [ -n "$MODEM_USERNAME" ] ; then
		echo "#################################################" > $PAPFILE
		echo "\"$MODEM_USERNAME\"	*	\"$MODEM_PASSWORD\"  *" >> $PAPFILE
		echo "#################################################" > $CHAPFILE
		echo "\"$MODEM_USERNAME\"	*	\"$MODEM_PASSWORD\"  *" >> $CHAPFILE
	fi

	# chat script
	echo "'' 'ATH'
'OK' 'ATZ'" > $CHAT
#'OK' 'ATI'" > $CHAT

	if [ "$MODEM_APN" != "" ]; then
		echo "'OK' 'AT+CGDCONT=1,\"IP\",\"$MODEM_APN\"'" >> $CHAT
	fi
	if [ -f $MODEM_AT_SETUP ]; then
		cat $MODEM_AT_SETUP >> $CHAT
	fi

	if [ "$MODEM_INIT_ATCMDS_ENABLED" = "Enabled" ]; then
		[ "$MODEM_INIT_ATCMDS1" != "" ] && echo "'OK' '$MODEM_INIT_ATCMDS1'" >> $CHAT
		[ "$MODEM_INIT_ATCMDS2" != "" ] && echo "'OK' '$MODEM_INIT_ATCMDS2'" >> $CHAT
		[ "$MODEM_INIT_ATCMDS3" != "" ] && echo "'OK' '$MODEM_INIT_ATCMDS3'" >> $CHAT
	fi

	echo "'OK' 'ATD$MODEM_PHONE_NUMBER' ABORT 'NO CARRIER' ABORT BUSY TIMEOUT 30
'CONNECT' 'ATO'
" >> $CHAT

	# config ppp
	echo_options lock crtscts local noipdefault \
	            "mtu $MODEM_MTU_SIZE" "mru $MODEM_MTU_SIZE" \
	            "lcp-echo-interval 30" "lcp-echo-failure 4" \
	             defaultroute usepeerdns noauth > $OPTIONS

	case $MODEM_AUTH_TYPE in
	Auto)  ;;
	PAP)   echo_options refuse-chap refuse-mschap refuse-mschap-v2 >> $OPTIONS ;;
	CHAP)  echo_options refuse-pap refuse-mschap refuse-mschap-v2 >> $OPTIONS ;;
	esac

	echo_options noccp nomppe "user \"$MODEM_USERNAME\"" \
	            "connect \"chat -s -V -t 5 -f $CHAT\"" >> $OPTIONS

	if [ -f $DEVTTYFILE ]; then
		DEVTTY=`cat $DEVTTYFILE`
	else
		DEVTTY=""
		modem-setup.sh ttyUSB0
	fi
}

. /bin/iface-names.sh

ln -sf /bin/ppp-up.sh /etc/ppp/ip-up
ln -sf /bin/ppp-down.sh /etc/ppp/ip-down

PHY_WAN_IP=`ifconfig $BOARD_INTERFACE_WAN 2> /dev/null | grep -i "inet addr:" | cut -f2 -d: | cut -f1 -d " "`
PHY_WAN_MASK=`ifconfig $BOARD_INTERFACE_WAN 2> /dev/null | grep -i "inet addr:" | cut -f4 -d: | cut -f1 -d " "`

start_connect() {
	eval `flash @PPP_USER_NAME @PPP_PASSWORD PPP_IP_ADDR PPP_SUBNET_MASK \
PPP_IDLE_TIME PPP_IP_AUTO PPP_IP_ADDR PPP_REMOTE_IP_ADDR \
PPP_REMOTE_SUBNET_MASK`
	echo "pass" > $CONNECTFILE
}


wait () {
	$*

	while [ "`pidof $1`" != '' ]; do
		sleep 1
	done
}


pppd_app() {
	echo $$ > $PPPDFILE
	trap "rm -f $PPPDFILE 2> /dev/null; launch \"/bin/pppd.sh stopped&\"; exit" TERM HUP INT

	case $PPP_TYPE in
	PPPoE)
		is_iface_up $BOARD_INTERFACE_WAN && {
			start_connect
			pppoe_build_options
			wait pppd
			rm $CONNECTFILE $LINKFILE 2> /dev/null
		}
		;;
	PPTP)
		if is_iface_up $BOARD_INTERFACE_WAN && add_server_route; then
			start_connect
			pptp_build_options
			wait pppd
			rm $CONNECTFILE $LINKFILE 2> /dev/null
		else
			echo 3 > $RESULTFILE
		fi
		reinit_wan
		;;
	L2TP)
		if is_iface_up $BOARD_INTERFACE_WAN && add_server_route; then
			start_connect
			l2tp_build_options
			wait pppd
			rm $CONNECTFILE $LINKFILE 2> /dev/null
		else
			echo 3 > $RESULTFILE
		fi
		reinit_wan
		;;
	modem)
		echo "pass" > $CONNECTFILE
		modem_setup
		:>/var/tmp/run_pppd
		if [ -n "$DEVTTY" ]; then 
			wait pppd /dev/$DEVTTY 921600 
		fi
		rm -f /var/tmp/run_pppd
		rm $CONNECTFILE $LINKFILE 2> /dev/null
		;;
	esac

	rm $PPPDFILE 2> /dev/null
	trap - TERM INT HUP
	launch "/bin/pppd.sh stopped&"
}


pppd_run() {
	if [ -f $PPPDFILE ]; then
		exit
	fi

	echo "Initializing..." > $STATUSFILE

	killall -1 pppd 2> /dev/null
	killall -1 pppd 2> /dev/null
	sleep 1
	killall -1 pppd 2> /dev/null
	killall -1 pppd 2> /dev/null
	sleep 1
	killall -1 pppd 2> /dev/null
	killall -1 pppd 2> /dev/null
	rm -f $LINKFILE 2> /dev/null

	[ ! -f $CONNECTFILE ] && pppd_app &
	return 0
}

pppd_abort() {
	rm "$CONNECTFILE" "$LINKFILE" 2> /dev/null
	:>$KILL
	case $PPP_TYPE in
	PPPoE|modem)
		killall -1 pppd 2> /dev/null
		sleep 1
		killall -9 pppd 2> /dev/null
		;;
	PPTP)
		killall -1 pppd 2> /dev/null
		sleep 1
		killall -9 pppd 2> /dev/null
		del_server_route
		;;
	L2TP)
		killall -1 pppd 2> /dev/null
		sleep 1
		killall -9 pppd 2> /dev/null
		del_server_route
		;;
	*)
		echo "pppd-$cmd: PPP_TYPE=($PPP_TYPE)"
		;;
	esac
	ifconfig ppp0 down 2> /dev/null

	rm -f $STATUSFILE $RESULTFILE $CHAINFILE
}


eval `flash OP_MODE PPP_TYPE PPP_SERVER MODEM_ENABLED`

if [ "$OP_MODE" = '3G Router' ]; then
	PPP_TYPE='None'
	if [ "$MODEM_ENABLED" = 'Enabled' ]; then 
		PPP_TYPE="modem"
	fi
fi

if [ "$PPP_TYPE" = 'None' ]; then
	exit 1
fi


case $1 in
start|connect)
	pppd_run
	;;

stopped)
	if [ -f "$KILL" ]; then
		rm $KILL
	else
		if [ ! -f $STATUSFILE ]; then
			echo "Pause" >> $STATUSFILE
		else
			eval `flash EZTUNE_ENABLED`
			
			if [ "$EZTUNE_ENABLED" = "Enabled" ]; then
				PPPRESULT=`cat $RESULTFILE`

				if [ "$PPPRESULT" = "5" ] ; then
					eztune.sh up
					dns.sh
					exit
				fi
			fi
		fi
		sleep 4
		pppd_run
	fi
	;;

disconnect)
	pppd_abort
	;;

reconnect)
	pppd_abort
	echo "Pause" > $STATUSFILE
	sleep 4
	pppd_run
	;;

stop|die)
	pppd_abort
	;;

*)
	echo "pppd.sh: Unknown ppp.sh command: '$1'"
	;;
esac
