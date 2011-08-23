#!/bin/sh

eval `flash NTP_ENABLED`
if [ "$NTP_ENABLED" = 'Disabled' ]; then
	exit 0
fi

while [ true ]; do

	eval `flash TIMEZONE NTP_SERVER`
	echo $TIMEZONE | cut -f1 -d ' ' > /etc/TZ

	zyntp -rfl -t 5 -c 12 $NTP_SERVER 2> /dev/null

	if [ $? -eq 0 ]; then
		for kill_sleep in `ps | grep -v grep |grep "sleep 3600"| cut -f1 -d "r"`; do
			kill -9 $kill_sleep 2> /dev/null
		done
		sleep 3600
	else
		sleep 60
	fi
done &

