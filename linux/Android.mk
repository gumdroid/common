LOCAL_PATH := $(call my-dir)

# This allows a kernel to be built from source as part of the Android
# build.  It expects a kernel source directory named 'kernel' to be
# located at the top of the Android source i.e. $(TOP)/kernel. The
# default 'droid' target will (re-)build the kernel as necessary
# whenever any of the kernel source is updated or the defconfig
# provided in the device directory is updated.  A 'linux' and
# 'clean-linux' target are also available so
#   $ m [clean]-linux
# does the expected thing but this is *not* an Android module so
#   $ mm
# ain't gonna work. For now, we don't install kernel headers.
#
# Some updates and inspiration from the msm AOSP kernel and
# http://nosemaj.org/howto-build-android-kitkat-nexus-5

ifneq ($(KERNEL_CONFIG),)
.phony: linux clean-linux
KERNEL_SOURCE_DIR := $(abspath $(TOP)/kernel)
KERNEL_BUILD_DIR := $(abspath $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ)
KERNEL_TOOLCHAIN_PREFIX := arm-eabi-

# for zImage (and dtbs)
TARGET_OUT_BOOT := $(TARGET_OUT)/boot
TARGET_OUT_MODULES := $(TARGET_OUT)/lib/modules
TARGET_OUT_FW := $(TARGET_OUT)/etc/firmware

# Technically, all output from a kernel built would be a target...but
# it is hard to build this list so just use zImage as the target as it
# will be updated each time the build is actually called.
KERNEL_OUTPUT_FILE := $(KERNEL_BUILD_DIR)/arch/$(TARGET_ARCH)/boot/zImage

# Top-level rule to actually install the desired output
# * the core build system expects a $(INSTALLED_KERNEL_TARGET) file
#   -- no name changes allowed
linux $(INSTALLED_KERNEL_TARGET): $(KERNEL_OUTPUT_FILE) $(ACP)
	$(hide) $(ACP) $(KERNEL_OUTPUT_FILE) $(INSTALLED_KERNEL_TARGET)

# corresponding convenience make target for cleaning
clean-linux:
	$(hide) -rm -rf $(INSTALLED_KERNEL_TARGET) $(TARGET_OUT_BOOT) $(TARGET_OUT_MODULES) $(TARGET_OUT_FW)
	$(hide) -$(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) mrproper

# make the build and boot output directories
$(KERNEL_BUILD_DIR) $(TARGET_OUT_BOOT):
	$(hide) mkdir -p $@

# Copy the product-specific defconfig (set as $(KERNEL_CONFIG)) as
# the kernel configuration.
$(KERNEL_BUILD_DIR)/.config: $(KERNEL_CONFIG) $(ACP) | $(KERNEL_BUILD_DIR)
	$(hide) $(ACP) $(KERNEL_CONFIG) $@
	$(hide) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) oldconfig

define install-kernel-extras
$(hide) -$(MAKE) INSTALL_MOD_PATH=$(abspath $(TARGET_OUT)) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) INSTALL_MOD_STRIP=1 modules_install &>/dev/null
$(hide) -$(MAKE) INSTALL_FW_PATH=$(abspath $(TARGET_OUT_FW)) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) firmware_install &>/dev/null
$(hide) -$(MAKE) INSTALL_DTBS_PATH=$(abspath $(TARGET_OUT_BOOT)) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) dtbs_install &>/dev/null
endef

# Consider all files in the KERNEL_SOURCE_DIR to be prerequsites for building
# the kernel.  If any source files change, update the build (remove zImage to
# ensure it is updated even if a rebuild doesn't particularly update it). Build
# and install the kernel image, any modules, standard firmware, and dtbs to
# /system.
$(KERNEL_OUTPUT_FILE): $(shell find $(KERNEL_SOURCE_DIR) -type f) $(KERNEL_BUILD_DIR)/.config $(ACP) | $(TARGET_OUT_BOOT)
	$(hide) rm -f $(KERNEL_OUTPUT_FILE)
	$(hide) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX)
	$(install-kernel-extras) || true
	$(hide) $(ACP) $@ $(TARGET_OUT_BOOT)/zImage

$(TARGET_OUT)/etc/canary: $(INSTALLED_KERNEL_TARGET)

endif # KERNEL_CONFIG
