#! /bin/sh

if [ "$1" = "" ]; then
	echo "parameter is none" 
	exit 1
fi
mounted=`mount | grep $1 | wc -l`
DISK_NAME=DISK_`echo $1| cut -b3,4,5,6 | tr [a-z] [A-Z]`
INIT=/media/DISK_A1/system/bin/ext_init.sh
INSTALL_DISK=$1
INSTALL_APPS=/media/$DISK_NAME/zyxel_install/apps.disk
MOUNT_APPS=/var/mnt
LOCK_APPS=/var/lock_apps
MODEM_STATUS=/var/usbstatus/modem
PRINTER_STATUS=/var/usbstatus/printer
STORAGE_STATUS=/var/usbstatus/storage
WIMAX_STATUS=/var/usbstatus/wimax
MOUNT=/media/DISK_A1/system
TORRENTS=/bin/transmission.sh

install_system() {
	if [ -f $INSTALL_APPS ] && [ ! -f $LOCK_APPS ]; then
		mkdir -p $MOUNT_APPS 2> /dev/null
		cp -f $INSTALL_APPS /var/tmp/ 2> /dev/null
		if ! mount -t squashfs /var/tmp/apps.disk $MOUNT_APPS; then
			rm -rf $LOCK_APPS /var/tmp/apps.disk $MOUNT_APPS 2> /dev/null
		else
			echo "good" > $LOCK_APPS
			/var/mnt/etc/init.d/dropbear start
			/bin/automount.sh $INSTALL_DISK
		fi
	fi
}

usb_device() {
	DISK_LIST=`mount | grep media | cut -f3 -d" " | cut -f3 -d/ | grep DISK`
	DISK_TEST=0
	
	for disk in $DISK_LIST; do
		DISK_TEST=1
	done
		
	if [ -f $PRINTER_STATUS ] || [ -f $MODEM_STATUS ] || [ -f $WIMAX_STATUS ] || [ $DISK_TEST = 1 ]; then
		ledctl 12
	else
		ledctl 13
	fi
	
	if [ $DISK_TEST = 1 ]; then
		> $STORAGE_STATUS
	else
		rm -f $STORAGE_STATUS 2> /dev/null
	fi
}

mkdir -p /var/usbstatus 2> /dev/null
# mounted, assume we umount
if [ $mounted -ge 1 ]; then
	if [ -x $TORRENTS ]; then
		$TORRENTS stop $DISK_NAME 2> /dev/null
	fi
	if [ -x $INIT ] && [ "$DISK_NAME" = "DISK_A1" ] && [ ! -f $LOCK_APPS ]; then
		$INIT stop automount 2> /dev/null
	fi
	COUNT=3
	while [ true ]; do
		# clean up services
		killall -9 nmbd smbd nqnd nqcs vsftpd stupid-ftpd transmissiond 2> /dev/null
		sync
		if ! umount "/media/$DISK_NAME"; then
			sleep 10
			COUNT=$((COUNT-1))
			if [ $COUNT = 0 ]; then
				exit 1
			fi
		else
			break
		fi
	done
	if ! rm -r "/media/$DISK_NAME"; then
		exit 1
	fi
	setup_users.sh
	usb_device
	# not mounted, lets mount under /media
else
	if ! mkdir -p "/media/$DISK_NAME"; then
		exit 1
	fi

	if ! mount -o utf8 "/dev/$1" "/media/$DISK_NAME"; then
		if ! mount "/dev/$1" "/media/$DISK_NAME"; then
		if ! ntfs-3g "/dev/$1" "/media/$DISK_NAME" -o force; then
			# failed to mount, clean up mountpoint
			if ! rm -r "/media/$DISK_NAME"; then
				exit 1
			fi
		fi
		fi	
	fi
	setup_users.sh
	usb_device
	if [ -x $INIT ] && [ "$DISK_NAME" = "DISK_A1" ] && [ ! -f $LOCK_APPS ]; then
		$INIT start automount 2> /dev/null &
	else
		install_system &
	fi
	if [ -x $TORRENTS ]; then
		$TORRENTS start $DISK_NAME 2> /dev/null &
	fi
fi

exit 0
