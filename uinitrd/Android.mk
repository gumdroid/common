LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := uinitrd

.phony: uinitrd clean-uinitrd

UINITRD_TARGET := $(PRODUCT_OUT)/boot/uInitrd
uinitrd: $(UINITRD_TARGET)

clean-uinitrd:
	$(hide) -rm $(UINITRD_TARGET)

# need uboot-mkimage installed...should really just get it from u-boot directory
# from some unknown reason, the prerequisite can't be INSTALLED_RAMDISK_TARGET...
$(UINITRD_TARGET): $(PRODUCT_OUT)/ramdisk.img
	$(hide) mkdir -p $(PRODUCT_OUT)/boot
	$(hide) mkimage -A $(TARGET_ARCH) -O linux -T ramdisk -C gzip -d $(INSTALLED_RAMDISK_TARGET) $@

# Pull this into the default 'droid' target
droid: uinitrd
