LOCAL_PATH := $(call my-dir)

ifdef UBOOT_CONFIG

include $(CLEAR_VARS)
LOCAL_MODULE := uboot

.phony: uboot clean-uboot

UBOOT_SOURCE_DIR := $(abspath $(TOP)/u-boot)
# need bare toolchain; android toolchain doesn't build u-boot
UBOOT_BARE_TOOLCHAIN := arm-eabi-
UBOOT_BUILD_DIR := $(abspath $(PRODUCT_OUT)/obj/u-boot)
UBOOT_OUTPUT_DIR := $(abspath $(PRODUCT_OUT)/boot)
UBOOT_OUTPUT_FILES := $(UBOOT_OUTPUT_DIR)/MLO $(UBOOT_OUTPUT_DIR)/u-boot.img

# build it and copy executables; avoid rebuilds if possible so don't reconfig. 
uboot_not_configured := $(wildcard $(UBOOT_BUILD_DIR)/.config)

uboot: $(UBOOT_OUTPUT_FILES)

# Consider all files in the UBOOT_SOURCE_DIR to be prerequsites for this
# target.  If any source files change, rebuild.
$(UBOOT_OUTPUT_FILES): $(shell find $(UBOOT_SOURCE_DIR) -type f)
	$(hide) mkdir -p $(UBOOT_BUILD_DIR)
ifeq ($(strip $(uboot_not_configured)),)
	$(hide) $(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR) CROSS_COMPILE=$(UBOOT_BARE_TOOLCHAIN) $(UBOOT_CONFIG)_config
endif
	$(hide) $(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR) CROSS_COMPILE=$(UBOOT_BARE_TOOLCHAIN)
	$(hide) mkdir -p $(UBOOT_OUTPUT_DIR)
	$(hide) cp $(UBOOT_BUILD_DIR)/MLO $(UBOOT_BUILD_DIR)/u-boot.img $(UBOOT_OUTPUT_DIR)

clean-uboot:
	$(hide) -$(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR) CROSS_COMPILE=$(UBOOT_BARE_TOOLCHAIN) distclean
	$(hide) -rm $(UBOOT_OUTPUT_FILES)

# Our device wants u-boot, so add this to the default 'droid' target
droid: uboot

endif # UBOOT_CONFIG
