# 
# Copyright (C) 2006 OpenWrt.org
# Copyright (C) 2010 ZyXEL.ru
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=binutils
PKG_VERSION:=$(strip $(subst ",, $(CONFIG_BINUTILS_VERSION)))
#"))

PKG_SOURCE_URL:=http://ftp.gnu.org/gnu/binutils/ \
	ftp://gatekeeper.dec.com/pub/GNU/ \
        ftp://ftp.uu.net/archive/systems/gnu/ \
        ftp://ftp.eu.uu.net/pub/gnu/ \
        ftp://ftp.funet.fi/pub/gnu/prep/ \
        ftp://ftp.leo.org/pub/comp/os/unix/gnu/ \
        http://www.kernel.org/pub/linux/devel/binutils/

PKG_SOURCE:=binutils-$(PKG_VERSION).tar.bz2
PATCH_DIR:=./patches/$(PKG_VERSION)
STAGING_DIR_HOST:=$(TOOLCHAIN_DIR)
BUILD_DIR_HOST:=$(BUILD_DIR_TOOLCHAIN)

include $(INCLUDE_DIR)/host-build.mk

ifeq ($(CONFIG_UCLIBC_NEW_METHOD_BUILD),y)
	SYSROOT_CONFIG:=--with-sysroot=$(TOOLCHAIN_DIR)
else
	SYSROOT_CONFIG:=
endif

define Build/Configure
	$(CP) $(SCRIPT_DIR)/config.{guess,sub} $(PKG_BUILD_DIR)/
	(cd $(PKG_BUILD_DIR); \
		./configure \
		--prefix=$(STAGING_DIR_HOST) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(SYSROOT_CONFIG) \
		--disable-werror \
		--disable-nls \
		$(SOFT_FLOAT_CONFIG_OPTION) \
		$(call qstrip,$(CONFIG_EXTRA_BINUTILS_CONFIG_OPTIONS)) \
	);
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all
endef

define Build/Install
	$(MAKE) -C $(PKG_BUILD_DIR) install
endef

$(eval $(call HostBuild))
