LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

PRODUCT_PACKAGES += \
    mkandroidsd

$(call inherit-product, $(SRC_TARGET_DIR)/product/core.mk)

.phony: gumstix bootfiles

# top-level make target
gumstix: droid bootfiles systemtarball userdatatarball

# dependencies for the bootfiles target are filled in by
# any packages that need to be included on the boot partition.
# PRODUCT_PACKAGES doesn't work as these aren't including
# the Android make classes.
bootfiles:
