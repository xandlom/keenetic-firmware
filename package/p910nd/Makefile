# 
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=p910nd
PKG_VERSION:=0.93
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/p910nd
PKG_MD5SUM:=f668eace7f424953c3aa48afcb34c62b

include $(INCLUDE_DIR)/package.mk

define Package/p910nd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A small non-spooling printer server
  URL:=http://p910nd.sourceforge.net
  SUBMENU:=printing
endef

define Package/p910nd/description
 p910nd is a small daemon that copies any data received on 
 the port it is listening on to the  corresponding printer 
 port. It  is primarily intended for diskless Linux hosts 
 running as printer drivers but there is no reason why it 
 could  not  be used on diskful hosts. Port 9100 is copied 
 to /dev/lp0, 9101 to /dev/lp1 and 9102 to /dev/lp2. The 
 default is port 9100 to /dev/lp0.
endef

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -DLOCKFILE_DIR=\"\\\"/tmp\"\\\""

define Package/p910nd/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/bin/
endef

$(eval $(call BuildPackage,p910nd))
