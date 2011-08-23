#!/bin/sh

echo 1 > /proc/sys/vm/overcommit_memory

if [ -x "/bin/mknod" ]; then
    mkdir /dev/rd
    mknod /dev/ac0 c 240 0
    mknod /dev/acl0 c 230 0
    mknod /dev/flash0 c 200 0    
    mknod /dev/hwnat0 c 220 0
    mknod /dev/i2cM0 c 218 0
    mknod /dev/I2S c 234 0
    mknod /dev/aci0 c 254 0
    mknod /dev/aci1 c 254 1
    mknod /dev/aci2 c 254 2
    mknod /dev/aci3 c 254 3
    mknod /dev/gpio c 252 0
    mknod /dev/gpio0 c 252 0
    mknod /dev/gpio1 c 252 1
    mknod /dev/rtled0 c 208 0
    mknod /dev/exe0 c 222 0
#    mknod /dev/mtd0 c 90 0
#    mknod /dev/mtd1 c 90 2
#    mknod /dev/mtd2 c 90 4
    mknod /dev/mtd3 c 90 6
    mknod /dev/mtd4 c 90 8
    mknod /dev/mtd5 c 90 10
    mknod /dev/mtd6 c 90 12
    mknod /dev/mtd7 c 90 14
    mknod /dev/mtd8 c 90 16
    mknod /dev/mtr0 c 250 0
    mknod /dev/PCM c 233 0
    mknod /dev/pppox0 c 144 0
    mknod /dev/pppox1 c 144 1
    mknod /dev/pppox2 c 144 2
    mknod /dev/pppox3 c 144 3
    mknod /dev/ptyp0 c 2 0
    mknod /dev/ptyp1 c 2 1
    mknod /dev/port c 1 4
    mknod /dev/ppp c 108 0
    mknod /dev/pts/0 c 136 0
    mknod /dev/pts/1 c 136 1
    mknod /dev/pts/2 c 136 2
    mknod /dev/pts/3 c 136 3
    mknod /dev/pts/4 c 136 4
    mknod /dev/pts/5 c 136 5
    mknod /dev/pts/6 c 136 6
    mknod /dev/pts/7 c 136 7
    mknod /dev/ram b 1 1
    mknod /dev/ram0 b 1 0
    mknod /dev/ram1 b 1 1
    mknod /dev/ram2 b 1 2
    mknod /dev/ram3 b 1 3
    mknod /dev/rdm0 c 254 0
    mknod /dev/spi0 c 153 0
    mknod /dev/spi1 c 153 1
    mknod /dev/spi2 c 153 2
    mknod /dev/spi3 c 153 3
    mknod /dev/tty0 c 4 0
    mknod /dev/tty1 c 4 1
#    mknod /dev/ttyS0 c 4 64
#    mknod /dev/ttyS1 c 4 65
    mknod /dev/spiS0 c 217 0
    mknod /dev/swnat0 c 210 0
    mknod /dev/usbdev1.1 c 189 0
    mknod /dev/usbdev2.1 c 189 128
    mknod /dev/usbdev3.1 c 190 0
    mknod /dev/usbdev4.1 c 190 128
    mknod /dev/usbdev5.1 c 191 0
    mknod /dev/usbdev6.1 c 191 128
#    mknod /dev/mtdblock0 b 31 0
#    mknod /dev/mtdblock1 b 31 1
#    mknod /dev/mtdblock2 b 31 2
    mknod /dev/mtdblock3 b 31 3
    mknod /dev/mtdblock4 b 31 4
    mknod /dev/mtdblock5 b 31 5
    mknod /dev/mtdblock6 b 31 6
    mknod /dev/mtdblock7 b 31 7
    mknod /dev/mtdblock8 b 31 8
    mknod /dev/rd/0 b 1 0
    mknod /dev/rd/1 b 1 1
    mknod /dev/rd/2 b 1 2
    mknod /dev/rd/3 b 1 3
    mknod /dev/rd/4 b 1 4
    mknod /dev/rd/5 b 1 5
    mknod /dev/rd/6 b 1 6
fi

MODULES="nf_conntrack_proto_gre nf_conntrack_pptp nf_nat_proto_gre nf_nat_pptp rtled ipt_ipp2p ipt_layer7 ipt_webstr xt_mac xt_mark rt_timer powerstat lm dwc_otg"

for modules in $MODULES; do
    insmod /lib/modules/2.6.23-rt/$modules.ko 2> /dev/null
done

if [ -x "/sbin/mdev" ]; then
    echo "/sbin/mdev" > /proc/sys/kernel/hotplug
    mdev -s
fi
