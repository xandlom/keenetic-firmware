#!/bin/sh

stop () {
	killall -9 syslogd 2> /dev/null
	killall klogd 2> /dev/null
}

if [ "$1" = "no_flash" ]; then
	syslogd -l 6 -s 100 -b 0 -S -L&
	exit 0
fi

eval `flash LOG_MODE REMOTELOG_SERVER`

if [ "$LOG_MODE" != 'Disabled' ] ;then

	if [ "$LOG_MODE" = 'Remote' ] ;then
		SYSLOG_PARA="-R $REMOTELOG_SERVER"
	fi

	mkdir /tmp/warm && {
		. /etc/version
		logger -t device $DEVICE_NAME \~ $FIRMWARE_VERSION \~ $BUILD_DATE
	}

	stop

	syslogd -s 100 -b 0 -S -L $SYSLOG_PARA &
	klogd &
else
	stop
	cat /dev/null > /var/log/messages
fi
