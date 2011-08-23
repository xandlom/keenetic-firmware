#!/bin/sh

eval `flash SERVICE_TAG_ACTIVATED`
if [ "$SERVICE_TAG_ACTIVATED" = 'Enabled' ]; then
	exit 0
fi

eval `flash OP_MODE LAN_DEFAULT_GATEWAY WAN_DNS1 WAN_DNS2 WAN_DNS3`
if [ "$OP_MODE" = 'WiFi Access Point' ] && [ "$LAN_DEFAULT_GATEWAY" = "0.0.0.0" -o "$WAN_DNS1" = "0.0.0.0" -a "$WAN_DNS2" = "0.0.0.0" -a "$WAN_DNS3" = "0.0.0.0" ]; then
	exit 0
fi

SERVICE="streg"
RESULTFILE=/var/tmp/streg.status
SERVICE_TAG=`ugetenv servicetag`
SERIAL_NUMBER=`ugetenv zyxelsn`

if [ "$SERVICE_TAG" = '' -o "$SERIAL_NUMBER" = '' ]; then
	exit 0
fi

while [ true ]; do
	sleep 60

	updatedd -- $SERVICE -t $SERVICE_TAG -s $SERIAL_NUMBER > $RESULTFILE 2>&1

	if [ $? -eq 0 ]; then
		flash set SERVICE_TAG_ACTIVATED 1
		exit 0
	fi
done &

