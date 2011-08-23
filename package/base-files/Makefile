#
# Copyright (C) 2010 ZyXEL.RU
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=base-files
PKG_RELEASE:=12

PKG_FILE_DEPEND:=$(PLATFORM_DIR)/

include $(INCLUDE_DIR)/package.mk

DEV_NAME = $(shell echo $(CONFIG_TARGET_DEVICE_NAME)|sed -e 's/ /-/g')
DATE_BUILD = $(shell date +"%d.%m.%Y %H:%M")

ifneq ($(REVISION),"")
SVNREVISION = $(shell echo $(REVISION)|sed -e 's/r//g')
else
SVNREVISION = "Unknown"
endif

ifneq ($(CONFIG_TARGET_VERSION),"")
  FIRMWARE_VER = $(shell echo $(CONFIG_TARGET_VERSION)|sed -e 's/(/-/g' -e 's/)/-/g')
else
  FIRMWARE_VER = $(SVNREVISION)
endif

ifneq ($(CONFIG_TARGET_DEV_CONSOLE),)
  DEV_CONSOLE=$(CONFIG_TARGET_DEV_CONSOLE)
else
  DEV_CONSOLE="ttyS0"
endif

ifneq ($(DUMP),1)
  TARGET:=-$(BOARD)
  ifneq ($(wildcard $(PLATFORM_DIR)/base-files-$(PROFILE) $(PLATFORM_SUBDIR)/base-files-$(PROFILE)),)
    TARGET:=$(TARGET)-$(PROFILE)
  endif
  LIBGCC_VERSION:=$(GCC_VERSION)
else
  LIBGCC_VERSION:=<LIBGCC_VERSION>
  UCLIBC_VERSION:=<UCLIBC_VERSION>
endif

CONFIG_PACKAGE_base-files$(TARGET):=$(CONFIG_PACKAGE_base-files)

define Package/base-files$(TARGET)
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Base filesystem for Keenetics
  URL:=http://www.zyxel.ru/
  VERSION:=$(PKG_RELEASE)-$(REVISION)
endef

define Package/base-files$(TARGET)/description
 This package contains a base filesystem and system scripts for OpenWrt.
endef

define Package/gcc/Default
  SECTION:=libs
  CATEGORY:=Base system
  DEPENDS:=@!NATIVE_TOOLCHAIN
  URL:=http://gcc.gnu.org/
  VERSION:=$(LIBGCC_VERSION)-$(PKG_RELEASE)
endef

define Package/libgcc
$(call Package/gcc/Default)
  TITLE:=GCC support library
  DEPENDS:=@!TARGET_avr32 @!NATIVE_TOOLCHAIN
endef

define Package/uclibc/Default
  SECTION:=libs
  CATEGORY:=Base system
  DEPENDS:=@!NATIVE_TOOLCHAIN
  URL:=http://uclibc.org/
  VERSION:=$(UCLIBC_VERSION)$(UCLIBC_PATCHVER)-$(PKG_RELEASE)
endef

define Package/libpthread
$(call Package/uclibc/Default)
  TITLE:=POSIX thread library
endef

define Package/uclibc
$(call Package/uclibc/Default)
  TITLE:=C library embedded systems
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/base-files$(TARGET)/install
	$(CP) ./files/* $(1)/
	mkdir -p $(1)/bin
	mkdir -p $(1)/etc
	mkdir -p $(1)/dev
	mkdir -p $(1)/lib
	mkdir -p $(1)/proc
	mkdir -p $(1)/sys
	mkdir -p $(1)/usr/lib
	mkdir -p $(1)/usr/bin
	mkdir -p $(1)/var
	ln -sf /var/hosts $(1)/etc/hosts
	ln -sf /var/tmp $(1)/tmp
	ln -sf /var/TZ $(1)/etc/TZ
	ln -sf /var/dnrd $(1)/etc/dnrd
	ln -sf /var/linuxgid $(1)/etc/linuxgid
	ln -sf /var/ppp $(1)/etc/ppp
	ln -sf /var/resolv.conf $(1)/etc/resolv.conf
	ln -sf /var/udhcpc $(1)/etc/udhcpc
	ln -sf /var/udhcpd $(1)/etc/udhcpd
	if [ -d $(PLATFORM_DIR)/base-files/. ]; then \
		$(CP) -r $(PLATFORM_DIR)/base-files/* $(1)/; \
	fi
	$(SED) 's|@tty@|$(DEV_CONSOLE)|g' $(1)/etc/inittab    
	$(SED) 's|"||g' $(1)/etc/inittab
	echo "FIRMWARE_VERSION=\"$(FIRMWARE_VER)\"" > $(1)/etc/version
	echo "DEVICE_NAME=\"$(DEV_NAME)\"" >> $(1)/etc/version
	echo "BUILD_DATE=\"$(DATE_BUILD)\"" >> $(1)/etc/version
	echo "REVISION=\"$(SVNREVISION)\"" >> $(1)/etc/version
endef

define Package/libgcc/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(TOOLCHAIN_DIR)/lib/libgcc_s.so.* $(1)/lib/
endef

define Package/libpthread/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(TOOLCHAIN_DIR)/lib/libpthread.so.* $(1)/lib/
	$(CP) $(TOOLCHAIN_DIR)/lib/libpthread-$(UCLIBC_VERSION).so $(1)/lib/
endef

define Package/uclibc/install
	$(INSTALL_DIR) $(1)/lib
	for file in ld-uClibc libc libcrypt libdl libm libnsl libresolv librt libuClibc libutil; do \
		$(CP) $(TOOLCHAIN_DIR)/lib/$$$$file.so.* $(1)/lib/; \
		$(CP) $(TOOLCHAIN_DIR)/lib/$$$$file-$(UCLIBC_VERSION).so $(1)/lib/; \
	done
endef

ifneq ($(DUMP),1)
  -include $(PLATFORM_DIR)/base-files.mk
endif

$(eval $(call BuildPackage,base-files$(TARGET)))
$(eval $(call BuildPackage,libgcc))
$(eval $(call BuildPackage,libpthread))
$(eval $(call BuildPackage,uclibc))
