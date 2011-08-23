#
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=vsftpd
PKG_VERSION:=2.3.4
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://vsftpd.beasts.org/users/cevans/
PKG_MD5SUM:=2ea5d19978710527bb7444d93b67767a

include $(INCLUDE_DIR)/package.mk

define Package/vsftpd
  SUBMENU:=FTP
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A fast and secure FTP server
  URL:=http://vsftpd.beasts.org/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE" \
		vsftpd
	$(CP) ./utils/* $(PKG_BUILD_DIR)/
	$(TARGET_CC) $(TARGET_CFLAGS) -o $(PKG_BUILD_DIR)/nologin $(PKG_BUILD_DIR)/nologin.c
	$(MAKE) -C "$(LINUX_DIR)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	ARCH="$(LINUX_KARCH)" \
	SUBDIRS="$(PKG_BUILD_DIR)/nf_conntrack_vsftp" \
	EXTRA_CFLAGS="$(BUILDFLAGS)" \
	modules
endef

define Package/vsftpd/install
	$(INSTALL_DIR) $(1)/etc
	ln -sf /var/$(PKG_NAME).conf $(1)/etc/$(PKG_NAME).conf
	ln -sf /var/ftpusers $(1)/etc/$(PKG_NAME).users
	ln -sf /var/$(PKG_NAME).passwd $(1)/etc/$(PKG_NAME).passwd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nologin $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./files/setup_ftp.sh $(1)/bin/
	$(INSTALL_DIR) $(1)/lib/modules/$(LINUX_VERSION)
	$(CP) $(PKG_BUILD_DIR)/nf_conntrack_vsftp/*.ko $(1)/lib/modules/$(LINUX_VERSION)/
endef

$(eval $(call BuildPackage,vsftpd))
