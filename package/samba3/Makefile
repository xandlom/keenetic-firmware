#
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=samba3
PKG_VERSION:=3.0.24
PKG_RELEASE:=2
#PKG_MD5SUM:=b51b2975f21006f85f7297f3fb1acde1

PKG_SOURCE_URL:=ftp://ftp.samba.org/pub/samba/old-versions/
PKG_SOURCE:=samba-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/samba-$(PKG_VERSION)/

include $(INCLUDE_DIR)/package.mk

define Package/samba3
  SECTION:=net
  CATEGORY:=Network
  TITLE:=samba3
  DEPENDS:=+libpthread
  URL:=http://www.samba.org/
  SUBMENU:=3rd Party Daemon
endef

define Package/samba3/Description
  Samba3 - made small with patches taken from AVM GPL releases and freetz 
endef

define Build/Prepare/LFS
	cat ./src/config-lfs.h >> $(PKG_BUILD_DIR)/source/include/config.h
endef

define Build/Prepare
$(call Build/Prepare/Default)
$(call Build/Prepare/LFS)
endef

define Build/Compile
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" \
	CPPFLAGS="$(TARGET_CPPFLAGS) -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR)/source \
		all bin/smbpasswd bin/libsmb.so bin/smbd.shared bin/nmbd.shared	
endef

define Package/samba3/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/bin/smbpasswd $(1)/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/bin/smbd.shared $(1)/bin/smbd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/bin/nmbd.shared $(1)/bin/nmbd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/source/bin/libsmb.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,samba3))
