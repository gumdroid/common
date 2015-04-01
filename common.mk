LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

PRODUCT_PACKAGES += \
    mkandroidsd

$(call inherit-product, $(SRC_TARGET_DIR)/product/core.mk)

.phony: gumstix

# top-level convenience make target
gumstix: droid systemtarball userdatatarball
