#!/bin/sh

SCRIPTFILE=/bin/dhclient-script.sh
PIDFILE=/etc/udhcpc/udhcpc-$1.pid

CMD="-i $1 -p $PIDFILE -s $SCRIPTFILE"

eval `flash DEVICE_NAME HOST_NAME`

if [ "$HOST_NAME" != ""  ]; then
	CMD="$CMD -h $HOST_NAME"
else
	CMD="$CMD -h $DEVICE_NAME"
fi

if [ -f $PIDFILE ] ; then
	PID=`cat $PIDFILE`
	if [ $PID != 0 ]; then
		kill -9 $PID 2> /dev/null
	fi
	rm -f $PIDFILE
fi

udhcpc -S $CMD
