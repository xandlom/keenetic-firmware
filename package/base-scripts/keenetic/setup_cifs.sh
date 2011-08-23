#! /bin/sh

if [ -e /bin/smbd ]; then
	/bin/setup_samba.sh
fi

if [ -e /bin/nqcs ]; then
	/bin/setup_nq.sh
fi

