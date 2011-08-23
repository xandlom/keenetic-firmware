#
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=base-scripts
PKG_RELEASE:=1
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Package/base-scripts
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Base scripts for KEENETICs
endef

define Package/base-scripts/description
	Base scripts for KEENETICs
endef

define Build/Compile
endef

define Package/base-scripts/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) ./all/* $(1)/bin/
	$(INSTALL_BIN) ./$(CONFIG_TARGET_BOARD)/* $(1)/bin/
endef

$(eval $(call BuildPackage,base-scripts))
