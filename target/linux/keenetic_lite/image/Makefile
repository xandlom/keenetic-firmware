# 
# Copyright (C) 2010 ZyXEL.RU
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Image/mkfs/prepare/default
	find $(TARGET_DIR) -type f -not -perm +0100 -not -name 'ssh_host*' | $(XARGS) chmod 0644
	find $(TARGET_DIR) -type f -perm +0100 | $(XARGS) chmod 0755
	find $(TARGET_DIR) -type d | $(XARGS) chmod 0755
endef

define Image/BuildKernel
	$(RM) $(KDIR)/vmlinux.lzma
	lzma e $(KDIR)/vmlinux $(KDIR)/vmlinux.lzma
	mkimage -A mips -O linux -T kernel -C lzma -a 0x80000000 -e $(shell readelf -h $(KDIR)/vmlinux.elf | grep "Entry" | awk '{print $$4}') \
	    -n "ZyXEL KEENETIC Series" -d  $(KDIR)/vmlinux.lzma $(BIN_DIR)/Kimage.lzma
	
endef

DEVICE_NAME=$(shell echo $(CONFIG_TARGET_DEVICE_NAME)|sed -e 's/ /_/g')

ifneq ($(CONFIG_TARGET_VERSION),"")
FIRMWARE_VER = $(DEVICE_NAME)-$(shell echo $(CONFIG_TARGET_VERSION)|sed -e 's/(/[/g' -e 's/)/]/g')
else
FIRMWARE_VER = $(DEVICE_NAME)-$(shell svnversion $(TOPDIR))
endif

FIRMWARE_NAME = Firmware-$(FIRMWARE_VER)_$(shell date +%y%m%d%H%M).bin
KERNEL_SIZE = $(shell echo $(CONFIG_TARGET_KERNEL_SIZE)|sed -e 's/"//g')
ROOTFS_SIZE = $(shell echo $(CONFIG_TARGET_ROOTFS_SIZE)|sed -e 's/"//g')
FW_SIZE = $(shell echo $$[$(KERNEL_SIZE)+$(ROOTFS_SIZE)])
DEVICE_ID=$(shell echo $(CONFIG_TARGET_DEVICE_ID)|sed -e 's/"//g')
COUNT = $(shell echo $$[$(KERNEL_SIZE)/65536])

define Image/Build
	cp $(KDIR)/root.squashfs $(BIN_DIR)/Rimage.squashfs
	@if [[ "`stat --printf="%s" $(BIN_DIR)/Kimage.lzma`" -gt $(CONFIG_TARGET_KERNEL_SIZE) ]] || \
	[[ "$(CONFIG_TARGET_KERNEL_SIZE) + `stat --printf="%s" $(BIN_DIR)/Rimage.squashfs`" -gt "$(FW_SIZE)" ]]; then \
	    echo -e "\aError: File size exceeded!!!!"; \
	else \
	    dd if=$(BIN_DIR)/Kimage.lzma of=$(BIN_DIR)/$(FIRMWARE_NAME) bs=65536 count=$(COUNT); \
	    dd if=$(BIN_DIR)/Rimage.squashfs of=$(BIN_DIR)/$(FIRMWARE_NAME) bs=65536 seek=$(COUNT) conv=sync; \
	    zyimage -v "ZyXEL $(FIRMWARE_VER)" -d $(DEVICE_ID) $(BIN_DIR)/$(FIRMWARE_NAME); \
	fi
endef

$(eval $(call BuildImage))
