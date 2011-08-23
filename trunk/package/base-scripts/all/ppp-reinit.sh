#! /bin/sh

. /bin/iface-names.sh

/bin/link_down.sh
sleep 5
/bin/link_up.sh
