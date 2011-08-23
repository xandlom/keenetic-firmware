#!/bin/sh

eval `flash SMB_ACCESS_ENABLED SMB_ANONYMOUS_ENABLED SMB_ANONYMOUS_FULLACCESS SMB_NAME SMB_WORKGROUP`

SMBPASSWD=/tmp/pwd_list.txt
SMBCONFIG=/tmp/cs_cfg.txt
SMBCONFIG_CM=/tmp/cm_cfg.txt
DISK_LIST1=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
DISK_LIST2=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
DISK_LIST3=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
WRITE_LIST=""

stop_samba() {
	killall -9 nqnd nqcs nqbr 2> /dev/null
}

start_samba() {
	stop_samba
	iptables -D INPUT -p udp -i lo -j ACCEPT 2> /dev/null
	iptables -A INPUT -p udp -i lo -j ACCEPT
	nqnd &
	sleep 1
#	nqbr &
#	sleep 1
	watcher /bin/nqcs &
}

global_smbconf() {
	/bin/nqex hostname $SMB_NAME $SMB_WORKGROUP
	echo "
DOMAIN=$SMB_WORKGROUP:W
" > $SMBCONFIG_CM
}

disk_smbconf() {
	for disk in $DISK_LIST2; do
		if [ "$disk" = "" ]; then
			continue
		fi
		echo "
$disk;/media/$disk;Hard Disk $disk Root;
" >> $SMBCONFIG
	done
}

samba_users() {
	flash :USERS_TBL | while read line; do
		eval $line
		echo "$name:$password:-$((idx+1))" >> $SMBPASSWD
	done
	if [ "$SMB_ANONYMOUS_ENABLED" = "Enabled" ]; then
		mv $SMBPASSWD $SMBPASSWD.input
	fi
}

if [ "$SMB_ACCESS_ENABLED" = "Enabled" ]; then
	rm -f $SMBPASSWD $SMBCONFIG $SMBCONFIG_CM 2> /dev/null
	if [ -n "$DISK_LIST1" ]; then
		global_smbconf
		samba_users
		disk_smbconf
		if [ -n "$DISK_LIST3" ]; then
			start_samba
		else
			rm -f $SMBPASSWD $SMBCONFIG $SMBCONFIG_CM 2> /dev/null
			stop_samba
		fi
	else
		stop_samba
	fi
else
	stop_samba
fi
