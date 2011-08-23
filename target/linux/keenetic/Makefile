# 
# Copyright (C) 2010 ZyXEL.ru
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=mipsel
BOARD:=keenetic
BOARDNAME:=ZyXEL Keenetic
FEATURES:=squashfs

LINUX_VERSION:=2.6.23-rt

define Target/Description
	Build firmware image for ZyXEL Keenetic
endef

# include the profiles
include $(INCLUDE_DIR)/target.mk

define Kernel/Prepare/Default 
	bzcat $(DL_DIR)/$(LINUX_SOURCE) | $(TAR) -C $(KERNEL_BUILD_DIR) $(TAR_OPTIONS)
	$(call PatchDir,$(GENERIC_PATCH_DIR),generic/)
	$(call PatchDir,$(PATCH_DIR),platform/) 
endef 

$(eval $(call BuildTarget))
