# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/host.mk

PKG_OS:=$(shell uname -s)
PKG_CPU:=$(shell uname -m)

SDK_NAME:=OpenWrt-SDK-$(BOARD)-for-$(PKG_OS)-$(PKG_CPU)
SDK_BUILD_DIR:=$(BUILD_DIR)/$(SDK_NAME)
EXCLUDE_DIRS:=*/ccache */stamp */man */share */stampfiles */info

all: compile

$(BIN_DIR)/$(SDK_NAME).tar.bz2: clean
	mkdir -p $(SDK_BUILD_DIR)/dl $(SDK_BUILD_DIR)/package
	$(CP) $(INCLUDE_DIR) $(SCRIPT_DIR) $(TOPDIR)/docs $(SDK_BUILD_DIR)/
	$(TAR) -cf - -C $(TOPDIR) $(foreach exclude,$(EXCLUDE_DIRS),--exclude="$(exclude)") --exclude="staging_dir/$(ARCH)" staging_dir | \
		$(TAR) -xf - -C $(SDK_BUILD_DIR)
	mkdir -p $(SDK_BUILD_DIR)/target/linux
	$(CP) $(GENERIC_PLATFORM_DIR) $(PLATFORM_DIR) $(SDK_BUILD_DIR)/target/linux/
	rm -rf \
		$(SDK_BUILD_DIR)/target/linux/*/files \
		$(SDK_BUILD_DIR)/target/linux/*/patches
	$(CP) \
		$(TOPDIR)/rules.mk \
		$(TOPDIR)/.config \
		./files/Makefile \
		./files/README.SDK \
		$(SDK_BUILD_DIR)/
	$(CP) \
		./files/package/rules.mk \
		$(TOPDIR)/package/Makefile \
		$(SDK_BUILD_DIR)/package/
	echo REVISION:="$(REVISION)" > $(SDK_BUILD_DIR)/include/version.mk
	find $(SDK_BUILD_DIR) -name .git | $(XARGS) rm -rf
	find $(SDK_BUILD_DIR) -name .svn | $(XARGS) rm -rf
	find $(SDK_BUILD_DIR) -name CVS | $(XARGS) rm -rf
	(cd $(BUILD_DIR); \
		tar cfj $@ $(SDK_NAME); \
	)

download:
prepare:
compile: $(BIN_DIR)/$(SDK_NAME).tar.bz2
install: compile

clean:
	rm -rf $(SDK_BUILD_DIR) $(BIN_DIR)/$(SDK_NAME).tar.bz2
