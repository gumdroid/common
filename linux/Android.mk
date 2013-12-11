LOCAL_PATH:= $(call my-dir)

ifdef KERNEL_CONFIG

include $(CLEAR_VARS)
LOCAL_MODULE := linux
.phony: linux clean-linux

KERNEL_SOURCE_DIR := $(abspath $(TOP)/kernel)
KERNEL_TOOLCHAIN_PREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
KERNEL_OUTPUT_DIR := $(abspath $(PRODUCT_OUT)/boot)

# build it and copy executables; avoid rebuilds if possible so don't reconfig. 
kernel_not_configured := $(wildcard $(KERNEL_BUILD_DIR)/.config)
linux:
ifeq ($(strip $(kernel_not_configured)),)
	$(hide) $(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) $(KERNEL_CONFIG)_defconfig
endif
	$(hide) $(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) uImage
	$(hide) mkdir -p $(KERNEL_OUTPUT_DIR)
	$(hide) $(ACP) $(KERNEL_SOURCE_DIR)/arch/arm/boot/uImage $(KERNEL_OUTPUT_DIR)/

clean-linux:
	$(hide) $(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) mrproper
	$(hide) -rm $(KERNEL_OUTPUT_DIR)/uImage

# Our device wants linux, add this to the bootfiles target
bootfiles: linux

endif # KERNEL_CONFIG
