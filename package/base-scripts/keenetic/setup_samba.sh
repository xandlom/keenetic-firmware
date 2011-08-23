#!/bin/sh

eval `flash SMB_ACCESS_ENABLED SMB_ANONYMOUS_ENABLED SMB_ANONYMOUS_FULLACCESS SMB_NAME SMB_WORKGROUP`

SMBPASSWD=/tmp/smbpasswd
SMBCONFIG=/tmp/smb.conf
TMP_LIST=/tmp/writelist
DISK_LIST1=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
DISK_LIST2=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
DISK_LIST3=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
WRITE_LIST=""

stop_samba() {
	killall -9 nmbd smbd 2> /dev/null
}

start_samba() {
	stop_samba
	nmbd -D
	smbd -D
}

global_smbconf() {
	echo "[global]
 interfaces = br0
 bind interfaces only = yes
 syslog = 0
 syslog only = yes
 socket options = TCP_NODELAY SO_KEEPALIVE SO_SNDBUF=16384 SO_RCVBUF=16384
 workgroup = $SMB_WORKGROUP
 netbios name = $SMB_NAME
 passdb backend = smbpasswd
 obey pam restrictions = yes
 map to guest = Bad User
 server string = NAS $SMB_NAME
 security = USER
 encrypt passwords = true
 guest account = nobody
 ; local master = yes
 load printers = no
 unix charset = UTF-8
 display charset = UTF-8
 dos charset = 866
 create mask = 0771
 force create mode = 0660
 force directory mode = 0771
 default case = upper
 preserve case = yes
 short preserve case = yes
 name resolve order = hosts bcast
" > $SMBCONFIG
}

disk_smbconf() {
	for disk in $DISK_LIST2; do
		if [ "$disk" = "" ]; then
			continue
		fi
		echo "[$disk]
 comment = NAS Media $disk
 path = /media/$disk
 browseable = yes
 printable = no" >> $SMBCONFIG

		if [ "$SMB_ANONYMOUS_ENABLED" = "Enabled" ]; then
			echo " public = yes" >> $SMBCONFIG
			if [ "$SMB_ANONYMOUS_FULLACCESS" = "Disabled" ]; then
				echo " read only = yes" >> $SMBCONFIG
				if [ -n "$WRITE_LIST" ]; then
					echo " write list = $WRITE_LIST" >> $SMBCONFIG
				fi
			else
				echo " read only = no
 guest only = yes" >> $SMBCONFIG
			fi
		else
			echo " read only = yes
 public = no" >> $SMBCONFIG
			if [ -n "$WRITE_LIST" ]; then
				echo " write list = $WRITE_LIST" >> $SMBCONFIG
			fi
		fi
		echo >> $SMBCONFIG
	done
}

samba_users() {
	flash USERS_TBL | while read line; do
		eval $line
		smbpasswd $name $password
		if [ "$fullAccess" = "Enabled" ]; then
			WRITE_LIST="$WRITE_LIST, $name"
			echo $WRITE_LIST > $TMP_LIST
		fi
	done
	if [ -f "$TMP_LIST" ]; then
		WRITE_LIST=`cat $TMP_LIST | cut -c3-`
		rm -f $TMP_LIST
	fi
}

if [ "$SMB_ACCESS_ENABLED" = "Enabled" ]; then
	rm -f $SMBPASSWD $SMBCONFIG 2> /dev/null
	if [ -n "$DISK_LIST1" ]; then
		global_smbconf
		samba_users
		disk_smbconf
		if [ -n "$DISK_LIST3" ]; then
			start_samba
		else
			rm -f $SMBPASSWD $SMBCONFIG 2> /dev/null
			stop_samba
		fi
	else
		stop_samba
	fi
else
	stop_samba
fi
