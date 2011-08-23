#!/bin/sh


if [ "$1" = "" ]; then
    echo
    echo "Please run ./configure.sh [target device]"
    echo "target device:"
    echo "              keenetic         - for ZyXEL KEENETIC."
    echo "              keenetic_4g      - for ZyXEL KEENETIC 4G."
    echo "              keenetic_lite    - for ZyXEL KEENETIC LITE."
    echo
    exit 1
fi
echo
echo -n "Creating configure file...."
cp -f ./configs/$1.config .config 2> /dev/null && {
			sleep 1
			echo " OK!"
			echo 
			echo "You can build firmware as \"make\" or \"make V=99\""
			echo
			exit 0 
}
sleep 1
echo " ERROR! Not found target device..."
echo
exit 1
