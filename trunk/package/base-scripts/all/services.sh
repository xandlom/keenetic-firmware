#!/bin/sh

# Start telnet server
eval `flash TELNET_ACCESS_PORT WEB_WAN_ACCESS_PORT TR069_ENABLED`
if [ -x "/usr/sbin/telnetd" ]; then
	echo -n $TELNET_ACCESS_PORT > /var/telnet_port
	/usr/sbin/telnetd -l /bin/cli -p $TELNET_ACCESS_PORT
fi

# Start debug telnet server
#eval `flash DEBUG`
#if [ $DEBUG = 1 ]; then
#	telnetd -p 1023
#fi

# start web server
echo -n $WEB_WAN_ACCESS_PORT > /var/websv_port
ln -sf /web /var/www
watcher /bin/websv -p $WEB_WAN_ACCESS_PORT &

# Daemon to monitor reset button and reset config
# btnreset &

# Remote tr069 management
if [ "$TR069_ENABLED" = 'Enabled' ]; then
	echo 'Starting TR069 agent'
	watcher /bin/cpeagent -F /etc/tr069/ -W /tmp/ &
fi

# Sysctl parameters
sysctl.sh

# Ready
ledctl 4
