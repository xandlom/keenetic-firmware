#
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=busybox
PKG_VERSION:=1.15.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.busybox.net/downloads \
		http://distfiles.gentoo.org/distfiles/
PKG_MD5SUM:=e67a98eef14212abfc265092e4683fbe

include $(INCLUDE_DIR)/package.mk

define Package/udhcpd-busybox
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Core utilities for embedded Linux (UDHCPD only)
  URL:=http://busybox.net/
endef

define Package/udhcpd-busybox/description
 The Swiss Army Knife of embedded Linux(UDHCPD only).
 It slices, it dices, it makes Julian Fries.
endef

define Build/Configure
	rm -f $(PKG_BUILD_DIR)/.configured*
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KBUILD_HAVE_NLS=no \
		ARCH="$(ARCH)" \
		oldconfig
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		KBUILD_HAVE_NLS=no \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="$(ARCH)" \
		IPKG_ARCH="$(ARCH)" \
		all
endef

define Package/udhcpd-busybox/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/udhcpd
endef

$(eval $(call BuildPackage,udhcpd-busybox))
