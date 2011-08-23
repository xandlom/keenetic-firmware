#!/bin/sh

# Support vsftpd

eval `flash get FTP_ACCESS_ENABLED FTP_ANONYMOUS_ENABLED FTP_ANONYMOUS_FULLACCESS FTP_PORT FTP_WAN_ACCESS_ENABLED OP_MODE`

DISK_LIST=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
FTPCONFIG=/var/vsftpd.conf
USERDIR=/var/ftpusers
PASSWD=/var/vsftpd.passwd
MOUNT_LOCK=/tmp/mount_lock.ftp
MAX_CLIENTS=10
MODULE=`lsmod | grep nf_conntrack_vsftp`
MODFTP=/lib/modules/2.6.23-rt/nf_conntrack_vsftp.ko
OLD_CFG=/var/tmp/vsftpd_old.cfg

rmmod_module() {
	if [ -n "$MODULE" ]; then
		rmmod nf_conntrack_vsftp 2> /dev/null
	fi
}

insmod_module() {
	if [ "$FTP_WAN_ACCESS_ENABLED" = 'Enabled' ] && [ "$OP_MODE" != 'WiFi Access Point' ] && [ "$OP_MODE" != 'Wireless Bridge' ]; then
		if [ "$FTP_PORT" = "2121" ]; then
			insmod $MODFTP 2> /dev/null
		elif [ "$FTP_PORT" != "21" ]; then
			insmod $MODFTP ports=$FTP_PORT 2> /dev/null
		fi
	fi
}

stop_ftp() {
	killall -9 vsftpd 2> /dev/null
	rmmod_module
}

start_ftp() {
	stop_ftp
	insmod_module
	vsftpd
}

ftpconf() {
	rm -f $FTPCONFIG 2> /dev/null
	echo "dirmessage_enable=yes
download_enable=no
dirlist_enable=no
hide_ids=yes
ftpd_banner=Welcome to FTP service.
syslog_enable=no
local_enable=yes
local_umask=022
chmod_enable=no
chroot_local_user=yes
check_shell=no
user_config_dir=$USERDIR
passwd_file=$PASSWD
listen=yes
listen_port=$FTP_PORT
background=yes
max_clients=$MAX_CLIENTS
idle_session_timeout=300
protect_writable_root=yes
utf8=yes
use_sendfile=no" > $FTPCONFIG

	if [ "$FTP_ANONYMOUS_ENABLED" = 'Enabled' ]; then
		echo "anon_allow_writable_root=yes
anon_world_readable_only=no
anon_umask=022" >> $FTPCONFIG
	if [ "$FTP_ANONYMOUS_FULLACCESS" = 'Enabled' ]; then
		echo "anon_upload_enable=yes
anon_mkdir_write_enable=yes
anon_other_write_enable=yes" >> $FTPCONFIG
	fi
	else
		echo "anonymous_enable=no" >> $FTPCONFIG
	fi
}

ftp_users() {
	rm -rf $USERDIR/* 2> /dev/null
	rm -f $PASSWD 2> /dev/null

	echo "ftp:x:0:0:ftp:/media:/usr/sbin/nologin
nobody:x:99:99:nobody:/var/run/ftpd:/sbin/nologin" > $PASSWD

	if [ "$FTP_ANONYMOUS_ENABLED" = 'Enabled' ]; then
		echo "dirlist_enable=yes
download_enable=yes" > $USERDIR/ftp
		if [ "$FTP_ANONYMOUS_FULLACCESS" = 'Enabled' ]; then
		echo "write_enable=yes" >> $USERDIR/ftp
		fi
	fi

	flash get @:USERS_TBL | while read line; do
		eval $line
		echo "dirlist_enable=yes
download_enable=yes" > $USERDIR/$name
		if [ "$fullAccess" = "Enabled" ]; then
			echo "write_enable=yes" >> $USERDIR/$name
		fi
		if [ -n "$password" ]; then
			passwd=`zyut crypt $password`
		else
			passwd=x
		fi
		echo "$name:$passwd:0:0:$name:/media:/usr/sbin/nologin" >> $PASSWD
	done
}

if [ -f $MOUNT_LOCK ]; then
	exit
fi
> $MOUNT_LOCK

if [ -f $OLD_CFG ]; then
	. $OLD_CFG
fi
iptables -D INPUT -p tcp --dport $FTP_PORT -j ACCEPT 2> /dev/null
eval `flash FTP_PORT`

if [ "$FTP_ACCESS_ENABLED" = "Enabled" ]; then
	if [ -n "$DISK_LIST" ]; then
		ftpconf
		ftp_users
		start_ftp
		echo "FTP_PORT=$FTP_PORT" > $OLD_CFG
		if [ "$FTP_WAN_ACCESS_ENABLED" = 'Enabled' ] && [ "$OP_MODE" != 'WiFi Access Point' ] && [ "$OP_MODE" != 'Wireless Bridge' ]; then
			iptables -A INPUT -p tcp --dport $FTP_PORT -j ACCEPT
		fi
	else
		stop_ftp
		rm -rf $USERDIR/* 2> /dev/null
		rm -f $PASSWD $FTPCONFIG 2> /dev/null
	fi
else
	stop_ftp
	rm -rf $USERDIR/* 2> /dev/null
	rm -f $PASSWD $FTPCONFIG 2> /dev/null
fi

rm -f $MOUNT_LOCK 2> /dev/null

