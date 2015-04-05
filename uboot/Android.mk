LOCAL_PATH := $(call my-dir)

# This allows the u-boot bootloader to be built from source as part of
# the Android build.  It expects a u-boot source directory named
# 'u-boot' to be located at the top of the Android source i.e.# $(TOP)/u-boot. The default 'droid' target will (re-)build u-boot
# $(TOP)/u-boot. The default 'droid' target will (re-)build u-boot
# as necessary whenever any of the u-boot source is updated. Set the
# UBOOT_CONFIG parameter in your BoardConfig.mk file to specify the
# u-boot target machine e.g. UBOOT_CONFIG := pepper.
# A 'uboot' and 'clean-uboot' target are also available so
#   $ m [clean]-uboot
# does the expected thing but this is *not* an Android module so
#   $ mm
# ain't gonna work.
ifdef UBOOT_CONFIG
.phony: uboot clean-uboot
UBOOT_SOURCE_DIR := $(abspath $(TOP)/u-boot)
UBOOT_BUILD_DIR := $(abspath $(TARGET_OUT_INTERMEDIATES)/UBOOT_OBJ)
UBOOT_TOOLCHAIN_PREFIX := arm-eabi-

UBOOT_BUILD_FILES := $(UBOOT_BUILD_DIR)/MLO $(UBOOT_BUILD_DIR)/u-boot.img
BOOT_PART_DIR := $(PRODUCT_OUT)/boot
UBOOT_OUTPUT_FILES := $(BOOT_PART_DIR)/MLO $(BOOT_PART_DIR)/u-boot.img

# Top-level rule to actually install the desired output. The core build
# system expects to ship an $(INSTALLED_2NDBOOTLOADER_TARGET) as part of
# the boot image.  Although we have both MLO and u-boot, just call
# u-boot.img the 2nd bootloader. Both MLO and u-boot.img will be installed
# in the boot/ folder in any case.
uboot $(INSTALLED_2NDBOOTLOADER_TARGET): $(BOOT_PART_DIR)/u-boot.img
	$(hide) $(ACP) $(UBOOT_BUILD_DIR)/u-boot.img $(INSTALLED_2NDBOOTLOADER_TARGET)

# Only depend on u-boot.img rather than both MLO and u-boot.img to avoid a race
# when doing a parallel make.  See [1] for the proper work-around.
# [1] http://stackoverflow.com/questions/2973445/gnu-makefile-rule-generating-a-few-targets-from-a-single-source-file
$(UBOOT_OUTPUT_FILES): $(UBOOT_BUILD_DIR)/u-boot.img | $(BOOT_PART_DIR)
	$(hide) $(ACP) $(UBOOT_BUILD_FILES) $(BOOT_PART_DIR)

clean-uboot:
	$(hide) -rm -f $(INSTALLED_BOOTLOADER_MODULE) $(UBOOT_OUTPUT_FILES)
	$(hide) -$(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR) CROSS_COMPILE=$(UBOOT_TOOLCHAIN_PREFIX) distclean

# make the build and boot output directories
$(UBOOT_BUILD_DIR) $(BOOT_PART_DIR):
	$(hide) mkdir -p $@

# Configure u-boot
$(UBOOT_BUILD_DIR)/.config: | $(UBOOT_BUILD_DIR)
	$(hide) $(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR)  CROSS_COMPILE=$(UBOOT_TOOLCHAIN_PREFIX) $(UBOOT_CONFIG)_defconfig

# Consider all files in the UBOOT_SOURCE_DIR to be prerequsites for this
# target.  If any source files change, rebuild.
$(UBOOT_BUILD_FILES): $(shell find $(UBOOT_SOURCE_DIR) -type f) $(UBOOT_BUILD_DIR)/.config | $(BOOT_PART_DIR)
	$(hide) $(MAKE) O=$(UBOOT_BUILD_DIR) -C $(UBOOT_SOURCE_DIR) CROSS_COMPILE=$(UBOOT_TOOLCHAIN_PREFIX)
	$(hide) $(ACP) $@ $(BOOT_PART_DIR)

endif # UBOOT_CONFIG
