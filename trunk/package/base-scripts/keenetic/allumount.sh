#!/bin/sh

if [ "fwupdate" = "$1" ]; then
	swapoff -a
	ALL_DISKS=`mount | grep "/dev/sd" | cut -f1 -d" " | cut -f3 -d "/"`
	if [ -n "$ALL_DISKS" ]; then
		for disk in $ALL_DISKS; do
			ledctl 14
			sync
			umount /dev/$disk
		done
	fi
	exit
fi

eval `flash TRNT_UMOUNT_BY_WPS_BUTTON`

if [ "$TRNT_UMOUNT_BY_WPS_BUTTON" = "Disabled" ]; then
	exit
fi

ALL_DISKS=`mount | grep "/dev/sd" | cut -f1 -d" " | cut -f3 -d "/"`

if [ -n "$ALL_DISKS" ]; then
	for disk in $ALL_DISKS; do
		ledctl 14
		/bin/automount.sh $disk
	done
else
	/bin/wps_query
fi
