# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ppp
PKG_VERSION:=2.4.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.samba.org/pub/ppp/
PKG_MD5SUM:=183800762e266132218b204dfb428d29

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

NO_CHAT=

ifeq ($(CONFIG_TARGET_BOARD),"keenetic_lite")
  NO_CHAT=y
endif

define Package/ppp/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://ppp.samba.org/
endef

define Package/ppp
$(call Package/ppp/Default)
  DEPENDS:=+kmod-ppp
  TITLE:=PPP daemon
  MENU:=1
endef

define Package/ppp/description
 This package contains the PPP (Point-to-Point Protocol) daemon.
endef

#define Package/ppp-mod-pppoa
#$(call Package/ppp/Default)
#  DEPENDS:=ppp +linux-atm +kmod-pppoa
#  TITLE:=PPPoA plugin
#endef

#define Package/ppp-mod-pppoa/description
# This package contains a PPPoA (PPP over ATM) plugin for ppp.
#endef

define Package/ppp-mod-pppoe
$(call Package/ppp/Default)
  DEPENDS:=ppp +kmod-pppoe
  TITLE:=PPPoE plugin
endef

define Package/ppp-mod-pppoe/description
 This package contains a PPPoE (PPP over Ethernet) plugin for ppp.
endef

define Package/ppp-mod-pptp
$(call Package/ppp/Default)
  DEPENDS:=ppp +kmod-pptp
  TITLE:=PPTP plugin
endef

define Package/ppp-mod-pptp/description
 This package contains a PPTP plugin
endef

define Package/ppp-mod-pppol2tp
$(call Package/ppp/Default)
  DEPENDS:=ppp +kmod-pppol2tp
  TITLE:=L2TP plugin
endef

define Package/ppp-mod-pppol2tp/description
 This package contains a L2TP plugin
endef

define Package/ppp-mod-radius
$(call Package/ppp/Default)
  DEPENDS:=ppp
  TITLE:=RADIUS plugin
endef

define Package/ppp-mod-radius/description
 This package contains a RADIUS (Remote Authentication Dial-In User 
 Service) plugin for ppp.
endef

define Build/Configure
$(call Build/Configure/Default,, \
	UNAME_S="Linux" \
	UNAME_R="$(LINUX_VERSION)" \
	UNAME_M="$(ARCH)" \
)
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)/usr
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		COPTS="$(TARGET_CFLAGS)" \
		STAGING_DIR="$(STAGING_DIR)" \
		DESTDIR="$(PKG_INSTALL_DIR)/usr" \
		all install
endef

define Package/ppp/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/pppd $(1)/usr/sbin/
ifneq ($(NO_CHAT),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/chat $(1)/usr/sbin/
endif
endef

	
#define Package/ppp-mod-pppoa/install
#	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
#	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pppd/$(PKG_VERSION)/pppoatm.so \
#		$(1)/usr/lib/pppd/$(PKG_VERSION)/
#endef

define Package/ppp-mod-pppoe/install
	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pppd/$(PKG_VERSION)/rp-pppoe.so \
		$(1)/usr/lib/pppd/$(PKG_VERSION)/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-discovery $(1)/bin/
endef

define Package/ppp-mod-pptp/install
	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pppd/$(PKG_VERSION)/pptp.so \
		$(1)/usr/lib/pppd/$(PKG_VERSION)/
endef

define Package/ppp-mod-pppol2tp/install
	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pppd/$(PKG_VERSION)/pppol2tp.so \
		$(1)/usr/lib/pppd/$(PKG_VERSION)/
endef

define Package/ppp-mod-radius/install
	$(INSTALL_DIR) $(1)/usr/lib/pppd/$(PKG_VERSION)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/pppd/$(PKG_VERSION)/radius.so \
		$(1)/usr/lib/pppd/$(PKG_VERSION)/
endef

$(eval $(call BuildPackage,ppp))
#$(eval $(call BuildPackage,ppp-mod-pppoa))
$(eval $(call BuildPackage,ppp-mod-pppoe))
$(eval $(call BuildPackage,ppp-mod-pptp))
$(eval $(call BuildPackage,ppp-mod-pppol2tp))
$(eval $(call BuildPackage,ppp-mod-radius))
