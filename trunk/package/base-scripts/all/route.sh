#!/bin/sh

eval `flash STATICROUTE_ENABLED`
if [ "$STATICROUTE_ENABLED" = 'Disabled' ]; then
	exit 0
fi

flash STATICROUTE_TBL | while read line; do
	eval $line
	route del -net $destaddr netmask $netmask gw $gateway 2> /dev/null
done

flash STATICROUTE_TBL | while read line; do
	eval $line
	if [ $metric = 0 ];then
		route add -net $destaddr netmask $netmask gw $gateway 2> /dev/null
	else
		route add -net $destaddr netmask $netmask gw $gateway metric $metric 2> /dev/null
	fi
done
