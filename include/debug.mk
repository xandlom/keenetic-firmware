# 
# Copyright (C) 2007 OpenWrt.org
# Copyright (C) 2010,2011 NDM Systems
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# debug flags:
#
# d: show subdirectory tree
# t: show added targets
# l: show legacy targets
# r: show autorebuild messages
# v: verbose (no .SILENCE for common targets)

ifeq ($(DUMP),)
  ifeq ($(DEBUG),all)
    build_debug:=dltvr
  else
    build_debug:=$(DEBUG)
  endif
endif

define debug
$$(findstring $(2),$$(if $$(DEBUG_DIR),$$(if $$(filter $$(DEBUG_DIR)%,$(1)),$(build_debug)),$(build_debug)))
endef

define warn
$$(if $(call debug,$(1),$(2)),$$(warning $(3)))
endef

define debug_eval
$$(if $(call debug,$(1),$(2)),$(3))
endef

define warn_eval
$(call warn,$(1),$(2),$(3)	$(4))
$(4)
endef


