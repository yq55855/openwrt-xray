include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-xray
PKG_VERSION:=5e18ae68b72f64d91ba1d1771a6f696f87148b8e
PKG_RELEASE:=1

PKG_LICENSE:=MPLv2
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=yichya <mail@yichya.dev>
PKG_SOURCE:=Xray-core-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/XTLS/Xray-core/tar.gz/${PKG_VERSION}?
PKG_HASH:=2632bf8abbd8a6e02a10da7829c65358d82ed5ae202c33a29a48d71a28d2865b
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/XTLS/Xray-core

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=Custom
	CATEGORY:=Extra packages
	TITLE:=Xray-core
	DEPENDS:=$(GO_ARCH_DEPENDS)
	PROVIDES:=xray-core
endef

define Package/$(PKG_NAME)/description
	Xray-core bare bones binary (compiled without cgo)
endef

define Package/$(PKG_NAME)/config
menu "Xray Configuration"
	depends on PACKAGE_$(PKG_NAME)

config PACKAGE_XRAY_ENABLE_GOPROXY_IO
	bool "Use goproxy.io to speed up module fetching (recommended for some network situations)"
	default n

endmenu
endef

USE_GOPROXY:=
ifdef CONFIG_PACKAGE_XRAY_ENABLE_GOPROXY_IO
	USE_GOPROXY:=GOPROXY=https://goproxy.io,direct
endif

MAKE_PATH:=$(GO_PKG_WORK_DIR_NAME)/build/src/$(GO_PKG)
MAKE_VARS += $(GO_PKG_VARS)

define Build/Patch
	$(CP) $(PKG_BUILD_DIR)/../Xray-core-$(PKG_VERSION)/* $(PKG_BUILD_DIR)
	$(Build/Patch/Default)
endef

define Build/Compile
	cd $(PKG_BUILD_DIR); $(GO_PKG_VARS) $(USE_GOPROXY) CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X github.com/xtls/xray-core/core.build=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)" -o $(PKG_INSTALL_DIR)/bin/xray ./main;
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/xray $(1)/usr/bin/xray
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
