#!/bin/sh

eval `flash OP_MODE WAN_MAC_ADDR WLAN_ENABLED WLAN_WMM_ENABLED \
WLAN_STA_MONITORING_ENABLED HIDE_SSID=WLAN_AP_HIDDEN_SSID \
WLAN_DTIM_PERIOD WLAN_BEACON_INTERVAL WLAN_COUNTRY_CODE \
WLAN_RTS_THRESHOLD WLAN_FRAG_THRESHOLD`

untext() {
	eval [ \"\$$1\" = \"$2\" ]
	eval "$1=$((!$?))"
}

untext WLAN_WMM_ENABLED Enabled
untext HIDE_SSID Enabled

wps_configured_status() {
	eval `flash WLAN_WPS_CONFIGURED AUTH_TYPE=WLAN_AP_AUTH_TYPE`
	case $AUTH_TYPE in
	*PSK*)
		if [ "$WLAN_WPS_CONFIGURED" = '0' ]; then
			flash set WLAN_WPS_CONFIGURED 1
		fi ;;
	*)
		if [ "$WLAN_WPS_CONFIGURED" = '1' ]; then
			flash set WLAN_WPS_CONFIGURED 0
		fi ;;
	esac
}

# Maps zycfg band (b g b/g a n g/n b/g/n) to the Ralink band
get_ralink_band() {
	local l o
	eval "l=\$$1";
	case $l in
	'802.11b')       o='1' ;;
	'802.11g')       o='4' ;;
	'802.11b/g')     o='0' ;;
	'802.11n')       o='6' ;;
	'802.11g/n')     o='7' ;;
	'802.11b/g/n'|*) o='9' ;;
	esac
	eval "$1=$o"
}

get_ralink_rate() {
	local l o
	eval "l=\$$1";
	case $l in
	'1M')     o=1 ;;
	'2M')     o=2 ;;
	'5.5M')   o=4 ;;
	'11M')    o=8 ;;
	'6M')     o=16 ;;
	'9M')     o=32 ;;
	'12M')    o=64 ;;
	'18M')    o=128 ;;
	'24M')    o=256 ;;
	'36M')    o=512 ;;
	'48M')    o=1024 ;;
	'54M')    o=2048 ;;
	*)        o=4095 ;;
	esac
	eval "$1=$o"
}

get_radio() {
	eval `flash SSID=WLAN_${1}_SSID \
CHANNEL=WLAN_${1}_CHANNEL \
REAL_BAND=WLAN_${1}_BAND \
BASIC_RATE=WLAN_${1}_FIX_RATE \
PREAMBLE_TYPE=WLAN_${1}_PREAMBLE_TYPE \
TXPOWER=WLAN_${1}_TXPOWER`

	get_ralink_band REAL_BAND
	get_ralink_rate BASIC_RATE

	AUTO_CHANNEL=$(($CHANNEL==0))
	untext PREAMBLE_TYPE Short
}

get_encryption() {
	eval `flash AUTH_TYPE=WLAN_${1}_AUTH_TYPE ENCRYPT_TYPE=WLAN_${1}_ENCRYPT_TYPE`
	case $AUTH_TYPE in
	None|Open)          AUTH='OPEN'    ;;
	Shared)             AUTH='SHARED'  ;;
	'WPA-PSK')          AUTH='WPAPSK'  ;;
	'WPA2-PSK')         AUTH='WPA2PSK' ;;
	'WPA-PSK/WPA2-PSK') AUTH='WPAPSKWPA2PSK' ;;
	esac

	ENCRYPT='NONE'
	if [ "$AUTH_TYPE" != 'None' ]; then
		case $ENCRYPT_TYPE in
		WEP64|WEP128) ENCRYPT='WEP' ;;
		TKIP)         ENCRYPT='TKIP' ;;
		AES)          ENCRYPT='AES' ;;
		'TKIP/AES')   ENCRYPT='TKIPAES' ;;
		esac
	fi

	[ "$1" = 'STA' -a "$ENCRYPT" = "TKIPAES" ] && \
		ENCRYPT='TKIP'

	eval `flash \
WEP_KEY1=WLAN_${1}_WEP_KEY1 \
WEP_KEY2=WLAN_${1}_WEP_KEY2 \
WEP_KEY3=WLAN_${1}_WEP_KEY3 \
WEP_KEY4=WLAN_${1}_WEP_KEY4 \
WEP_KEY1_FORMAT=WLAN_${1}_WEP_KEY1_FORMAT \
WEP_KEY2_FORMAT=WLAN_${1}_WEP_KEY2_FORMAT \
WEP_KEY3_FORMAT=WLAN_${1}_WEP_KEY3_FORMAT \
WEP_KEY4_FORMAT=WLAN_${1}_WEP_KEY4_FORMAT \
WEP_KEY_INDEX=WLAN_${1}_WEP_KEY_INDEX \
WPA_PSK=WLAN_${1}_WPA_PSK`

	untext WEP_KEY1_FORMAT ASCII
	untext WEP_KEY2_FORMAT ASCII
	untext WEP_KEY3_FORMAT ASCII
	untext WEP_KEY4_FORMAT ASCII
}


create_config_ap() {
	echo "#The word of \"Default\" must not be removed
Default
CountryRegion=1
CountryRegionABand=0
CountryCode=$WLAN_COUNTRY_CODE
BssidNum=1
SSID=$SSID
WirelessMode=$REAL_BAND
TxRate=0
Channel=$CHANNEL
BasicRate=$BASIC_RATE
BeaconPeriod=$WLAN_BEACON_INTERVAL
DtimPeriod=$WLAN_DTIM_PERIOD
TxPower=$TXPOWER
DisableOLBC=0
BGProtection=0
TxAntenna=
RxAntenna=
TxPreamble=$PREAMBLE_TYPE
RTSThreshold=$WLAN_RTS_THRESHOLD
FragThreshold=$WLAN_FRAG_THRESHOLD
TxBurst=1
PktAggregate=0
TurboRate=0
WmmCapable=$WLAN_WMM_ENABLED
APAifsn=3;7;1;1
APCwmin=4;4;3;2
APCwmax=6;10;4;3
APTxop=0;0;94;47
APACM=0;0;0;0
BSSAifsn=3;7;2;2
BSSCwmin=4;4;3;2
BSSCwmax=10;10;4;3
BSSTxop=0;0;94;47
BSSACM=0;0;0;0
AckPolicy=0;0;0;0
NoForwarding=0
NoForwardingBTNBSSID=0
HideSSID=$HIDE_SSID
ShortSlot=1
AutoChannelSelect=$AUTO_CHANNEL
IEEE8021X=0
IEEE80211H=0
CSPeriod=10
WirelessEvent=0
PreAuth=0
AuthMode=$AUTH
EncrypType=$ENCRYPT
RekeyInterval=0
RekeyMethod=DISABLE
PMKCachePeriod=10
WPAPSK=$WPA_PSK
DefaultKeyID=$WEP_KEY_INDEX
Key1Type=$WEP_KEY1_FORMAT
Key1Str=$WEP_KEY1
Key2Type=$WEP_KEY2_FORMAT
Key2Str=$WEP_KEY2
Key3Type=$WEP_KEY3_FORMAT
Key3Str=$WEP_KEY3
Key4Type=$WEP_KEY4_FORMAT
Key4Str=$WEP_KEY4
HSCounter=0
AccessPolicy0=0
AccessControlList0=
AccessPolicy1=0
AccessControlList1=
AccessPolicy2=0
AccessControlList2=
AccessPolicy3=0
AccessControlList3=
WdsEnable=0
WdsEncrypType=NONE
WdsList=
WdsKey=
RADIUS_Server=192.168.1.1
RADIUS_Port=1812
RADIUS_Key=ralink
own_ip_addr=192.168.1.2
EAPifname=br0
PreAuthifname=br0
HT_HTC=0
HT_RDG=1
HT_EXTCHA=0
HT_LinkAdapt=0
HT_OpMode=0
HT_MpduDensity=5
HT_BW=1
HT_AutoBA=1
HT_AMSDU=0
HT_BAWinSize=64
HT_GI=1
HT_STBC=1
HT_MCS=33
" > /tmp/RT2860.dat
}


create_config_sta() {
	echo "#The word of \"Default\" must not be removed
Default
CountryRegion=1
CountryRegionABand=0
CountryCode=$WLAN_COUNTRY_CODE
BssidNum=1
SSID=$SSID
NetworkType=Infra
WirelessMode=$REAL_BAND
TxRate=0
Channel=$CHANNEL
BasicRate=$BASIC_RATE
BeaconPeriod=$WLAN_BEACON_INTERVAL
DtimPeriod=$WLAN_DTIM_PERIOD
TxPower=$TXPOWER
DisableOLBC=0
BGProtection=0
TxAntenna=
RxAntenna=
TxPreamble=$PREAMBLE_TYPE
RTSThreshold=$WLAN_RTS_THRESHOLD
FragThreshold=$WLAN_FRAG_THRESHOLD
TxBurst=1
PktAggregate=0
TurboRate=0
WmmCapable=$WLAN_WMM_ENABLED
APAifsn=3;7;1;1
APCwmin=4;4;3;2
APCwmax=6;10;4;3
APTxop=0;0;94;47
APACM=0;0;0;0
BSSAifsn=3;7;2;2
BSSCwmin=4;4;3;2
BSSCwmax=10;10;4;3
BSSTxop=0;0;94;47
BSSACM=0;0;0;0
AckPolicy=0;0;0;0
NoForwarding=0
NoForwardingBTNBSSID=0
HideSSID=0
ShortSlot=1
AutoChannelSelect=$AUTO_CHANNEL
IEEE8021X=0
IEEE80211H=0
CSPeriod=10
PreAuth=0
AuthMode=$AUTH
EncrypType=$ENCRYPT
RekeyInterval=0
RekeyMethod=DISABLE
PMKCachePeriod=10
WPAPSK=$WPA_PSK
DefaultKeyID=$WEP_KEY_INDEX
Key1Type=$WEP_KEY1_FORMAT
Key1Str=$WEP_KEY1
Key2Type=$WEP_KEY2_FORMAT
Key2Str=$WEP_KEY2
Key3Type=$WEP_KEY3_FORMAT
Key3Str=$WEP_KEY3
Key4Type=$WEP_KEY4_FORMAT
Key4Str=$WEP_KEY4
HSCounter=0
AccessPolicy0=0
AccessControlList0=
AccessPolicy1=0
AccessControlList1=
AccessPolicy2=0
AccessControlList2=
AccessPolicy3=0
AccessControlList3=
WdsEnable=0
WdsEncrypType=NONE
WdsList=
WdsKey=
RADIUS_Server=192.168.2.3
RADIUS_Port=1812
RADIUS_Key=ralink
own_ip_addr=192.168.5.234
Ethifname=eth0
HT_HTC=0
HT_RDG=1
HT_EXTCHA=0
HT_LinkAdapt=0
HT_OpMode=1
HT_MpduDensity=4
HT_BW=1
HT_AutoBA=1
HT_AMSDU=1
HT_BAWinSize=8
HT_GI=1
HT_STBC=0
HT_MCS=33
" > /tmp/RT2860.dat
}

wlan_link_monitor() {
	LINKMOD=/lib/modules/2.6.23-rt/wilink.ko
	MODULE=`lsmod | grep wilink`
	if [ -n "$MODULE" ] && [ "$OP_MODE" != 'WiFi Router' ]; then
		rmmod wilink 2> /dev/null
	fi
	if [ "$OP_MODE" = 'WiFi Router' ] && \
	   [ "$WLAN_STA_MONITORING_ENABLED" = 'Enabled' ] && \
	   [ ! -n "$MODULE" ] && \
	   [ -f "$LINKMOD" ]; then
		insmod $LINKMOD 2> /dev/null
	fi
}

. /bin/iface-names.sh

MODULE=`lsmod | grep rt2860 | cut -d " " -f 1`
if [ -n "$MODULE" ]; then
	ifconfig $BOARD_INTERFACE_WIRELESS_LAN down 2> /dev/null
	rmmod $MODULE 2> /dev/null
fi

if [ "$WLAN_ENABLED" = 'Disabled' ]; then
	insmod /lib/modules/2.6.23-rt/rtled.ko power_on=1 2> /dev/null
	ledctl 21
	exit
fi

if [ "$OP_MODE" = 'WiFi Router' -o "$OP_MODE" = 'Wireless Bridge' ]; then
	get_encryption STA
	get_radio STA
	create_config_sta

	insmod /lib/modules/2.6.23-rt/rtled.ko power_on=1 2> /dev/null
	if [ "$WAN_MAC_ADDR" != "00:00:00:00:00:00" ]; then
		insmod /lib/modules/2.6.23-rt/rt2860v2_sta.ko mac=$WAN_MAC_ADDR 2> /dev/null
	else
		insmod /lib/modules/2.6.23-rt/rt2860v2_sta.ko 2> /dev/null
	fi
	wlan_link_monitor
else
	get_encryption AP
	get_radio AP
	create_config_ap

	wps_configured_status
	insmod /lib/modules/2.6.23-rt/rtled.ko power_on=1 2> /dev/null
	insmod /lib/modules/2.6.23-rt/rt2860v2_ap.ko 2> /dev/null
fi
