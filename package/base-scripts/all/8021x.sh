#!/bin/sh

. /bin/iface-names.sh

WPA_CONF=/var/8021x.conf

eval `flash @WAN_DOT1X_USER_NAME @WAN_DOT1X_PASSWORD WAN_DOT1X_AUTH_TYPE`

echo "ap_scan=0" > $WPA_CONF
echo "network={" >> $WPA_CONF
echo "key_mgmt=IEEE8021X" >> $WPA_CONF
if [ "$WAN_DOT1X_AUTH_TYPE" = 'EAP_MD5' ]; then
	echo "eap=MD5" >> $WPA_CONF
else
	echo "eap=TTLS" >> $WPA_CONF
fi
echo "identity=\"$WAN_DOT1X_USER_NAME\"" >> $WPA_CONF
echo "password=\"$WAN_DOT1X_PASSWORD\"" >> $WPA_CONF
if [ "$WAN_DOT1X_AUTH_TYPE" = 'CHAP' ]; then
	echo "anonymous_identity=\"anonymous\"" >> $WPA_CONF
	echo "phase2=\"autheap=CHAP\"" >> $WPA_CONF
elif [ "$WAN_DOT1X_AUTH_TYPE" = 'MS-CHAP v1' ]; then
	echo "anonymous_identity=\"anonymous\"" >> $WPA_CONF
	echo "phase2=\"autheap=MSCHAP\"" >> $WPA_CONF
elif [ "$WAN_DOT1X_AUTH_TYPE" = 'MS-CHAP v2' ]; then
	echo "anonymous_identity=\"anonymous\"" >> $WPA_CONF
	echo "phase2=\"autheap=MSCHAPV2\"" >> $WPA_CONF
fi
echo "eapol_flags=0" >> $WPA_CONF
echo "}" >> $WPA_CONF

wpa_supplicant -Dwired -i $BOARD_INTERFACE_WAN -c $WPA_CONF -dd -B

