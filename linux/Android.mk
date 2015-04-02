LOCAL_PATH := $(call my-dir)

ifdef KERNEL_CONFIG_SRC

KERNEL_SOURCE_DIR := $(abspath $(TOP)/kernel)
KERNEL_TOOLCHAIN_PREFIX := arm-eabi-
KERNEL_BUILD_DIR := $(abspath $(PRODUCT_OUT)/obj/kernel)
KERNEL_OUTPUT_DIR := $(abspath $(PRODUCT_OUT)/system)
KERNEL_CONFIG_BUILD := $(KERNEL_BUILD_DIR)/.config

# Technically, all output from a kernel built would be a target...but
# it is hard to build this list so just use zImage as the target as it
# will be updated each time the build is actually called.
KERNEL_OUTPUT_FILE := $(KERNEL_OUTPUT_DIR)/boot/zImage

linux: $(KERNEL_OUTPUT_FILE)

$(KERNEL_CONFIG_BUILD): $(KERNEL_CONFIG_SRC) | $(KERNEL_BUILD_DIR)
	$(hide) $(ACP) $(KERNEL_CONFIG_SRC) $(KERNEL_CONFIG_BUILD)
	$(hide) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) oldconfig

$(KERNEL_BUILD_DIR) $(KERNEL_OUTPUT_DIR)/boot:
	$(hide) mkdir -p $@

# Consider all files in the KERNEL_SOURCE_DIR to be prerequsites for this
# target.  If any source files change, rebuild.
$(KERNEL_OUTPUT_FILE): $(shell find $(KERNEL_SOURCE_DIR) -type f) $(KERNEL_CONFIG_BUILD) | $(KERNEL_OUTPUT_DIR)/boot
	$(hide) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX)
	$(hide) INSTALL_MOD_PATH=$(KERNEL_OUTPUT_DIR) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) modules_install
	$(hide) INSTALL_MOD_PATH=$(KERNEL_OUTPUT_DIR) $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) firmware_install
	$(hide) -INSTALL_DTBS_PATH=$(KERNEL_OUTPUT_DIR)/boot $(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) dtbs_install
	$(hide) -rm -r $(KERNEL_OUTPUT_DIR)/boot.old
	$(hide) cp $(KERNEL_BUILD_DIR)/arch/arm/boot/zImage $(KERNEL_OUTPUT_DIR)/boot/

# Make this a double-colon rule to match rules automatically created for
# LOCAL_MODULE := linux.  This extends the meaning of 'clean-linux'.
clean-linux::
	$(hide) -$(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) mrproper
	$(hide) -rm -r $(KERNEL_OUTPUT_DIR)/lib/modules
	$(hide) -rm -r $(KERNEL_OUTPUT_DIR)/lib/firmware
	$(hide) -rm -r $(KERNEL_OUTPUT_DIR)/boot
	$(hide) -rm -r $(KERNEL_OUTPUT_DIR)/boot.old

include $(CLEAR_VARS)
LOCAL_MODULE := linux
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := FAKE
include $(BUILD_PREBUILT)

endif # KERNEL_CONFIG_SRC
