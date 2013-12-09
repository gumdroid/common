LOCAL_PATH:= $(call my-dir)

ifdef KERNEL_CONFIG
include $(CLEAR_VARS)
KERNEL_SOURCE_DIR := $(abspath $(TOP)/kernel)
KERNEL_TOOLCHAIN_PREFIX := $(shell basename $(TARGET_TOOLS_PREFIX))
KERNEL_OUTPUT_DIR := $(abspath $(PRODUCT_OUT)/boot)

.phony: build-kernel clean-kernel

# build it and copy executables; avoid rebuilds if possible so don't reconfig. 
kernel_not_configured := $(wildcard $(KERNEL_BUILD_DIR)/.config)
build-kernel:
ifeq ($(strip $(kernel_not_configured)),)
	$(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) $(KERNEL_CONFIG)_defconfig
endif
	$(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) uImage
	@-mkdir -p $(KERNEL_OUTPUT_DIR)
	$(ACP) $(KERNEL_SOURCE_DIR)/arch/arm/boot/uImage $(KERNEL_OUTPUT_DIR)/

clean-kernel:
	$(MAKE) -C $(KERNEL_SOURCE_DIR) ARCH=arm CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) mrproper
	-rm $(KERNEL_OUTPUT_DIR)/uImage
endif
