LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

## Setup *distro*-type choices for Gumstix
PRODUCT_CHARACTERISTICS := nosdcard
DEVICE_PACKAGE_OVERLAYS := device/gumstix/common/overlay

# Precise garbage collection
PRODUCT_TAGS += dalvik.gc.type-precise

# Don't add visual fault overlays to our eng build
PRODUCT_PROPERTY_OVERRIDES += \
        persist.sys.strictmode.visual=0 \
        persist.sys.strictmode.disable=1

# System Utilities
PRODUCT_PACKAGES += \
        fs_get_stats \
        dhcpcd.conf \
        make_ext4fs

# Audio utils
PRODUCT_PACKAGES += \
        tinycap \
        tinymix \
        tinyplay \
        libsrec_jni

# Live Wallpapers
PRODUCT_PACKAGES += \
        LiveWallpapers \
        LiveWallpapersPicker \
        MagicSmokeWallpapers \
        VisualizationWallpapers

# Gumstix-specific packages
PRODUCT_PACKAGES += \
    mkandroidsd \
    devmem2 \
    canary

.phony: gumstix

# top-level convenience make target
gumstix: droid systemtarball userdatatarball
