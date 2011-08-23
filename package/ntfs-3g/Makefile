#
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntfs-3g
PKG_VERSION:=2010.1.16
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=http://tuxera.com/opensource/
PKG_MD5SUM:=e104c914e8d7d29ee83e63d46afbba25

include $(INCLUDE_DIR)/package.mk

define Package/ntfs-3g
  TITLE:=NTFS-3G
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=http://www.ntfs-3g.org
  SUBMENU:=filesystem
endef

define Package/ntfs-3g/description
  This package contains the third generation Read/Write NTFS driver
endef

CONFIGURE_ARGS += --with-fuse=internal

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS) -O2 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Package/ntfs-3g/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ntfs-3g $(1)/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libntfs-3g.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,ntfs-3g))
