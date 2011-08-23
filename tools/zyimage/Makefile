#
# Copyright (C) 2010,2011 NDM Systems
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=zyimage

include $(INCLUDE_DIR)/host-build.mk

define Build/Compile
endef

define Build/Install
	$(CP) src/zyimage $(STAGING_DIR_HOST)/bin/
endef

define Build/Clean
	rm -f $(STAGING_DIR_HOST)/bin/zyimage
endef

$(eval $(call HostBuild))
