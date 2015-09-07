ifeq ($(TARGET_DEVICE),pepper)

.PHONY: wl18xx-km clean-wl18xx-km
WL18XX_KM_SRC_DIR := $(abspath $(TOP)/device/gumstix/common/wl18xx)
WL18XX_KM_BUILD_DIR := $(abspath $(TARGET_OUT_INTERMEDIATES)/WL18XX_OBJ)
WL18XX_KM_OUT_DIR := $(TARGET_OUT)/etc/wl18xx

WL18XX_KM_SRC_FILES := $(shell find $(WL18XX_KM_SRC_DIR) -type f)
WL18XX_KM_BUILD_FILES := $(patsubst $(WL18XX_KM_SRC_DIR)/%,$(WL18XX_KM_BUILD_DIR)/%,$(WL18XX_KM_SRC_FILES))
WL18XX_KM_BUILD_OUTPUT := $(WL18XX_KM_BUILD_DIR)/compat/compat.ko $(WL18XX_KM_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore.ko $(WL18XX_KM_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko $(WL18XX_KM_BUILD_DIR)/drivers/net/wireless/ti/wl18xx/wl18xx.ko $(WL18XX_KM_BUILD_DIR)/net/mac80211/mac80211.ko $(WL18XX_KM_BUILD_DIR)/net/wireless/cfg80211.ko
WL18XX_KM_OUTPUT_FILES := $(WL18XX_KM_OUT_DIR)/compat/compat.ko $(WL18XX_KM_OUT_DIR)/drivers/net/wireless/ti/wlcore/wlcore.ko $(WL18XX_KM_OUT_DIR)/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko $(WL18XX_KM_OUT_DIR)/drivers/net/wireless/ti/wl18xx/wl18xx.ko $(WL18XX_KM_OUT_DIR)/net/mac80211/mac80211.ko $(WL18XX_KM_OUT_DIR)/net/wireless/cfg80211.ko

# Hook onto the 'canary' target
# use an intermediate as we've got multiple build outputs
# http://stackoverflow.com/questions/2973445/gnu-makefile-rule-generating-a-few-targets-from-a-single-source-file
$(TARGET_OUT)/etc/canary wl18xx-km $(WL18XX_KM_OUTPUT_FILES): wl18xx-km-output.intermediate

.INTERMEDIATE: wl18xx-km-output.intermediate
# build and copy output
wl18xx-km-output.intermediate: $(WL18XX_KM_BUILD_FILES) $(INSTALLED_KERNEL_TARGET) $(ACP) | $(WL18XX_KM_OUT_DIR)
	$(hide) rm -f $(WL18XX_KM_BUILD_OUTPUT)
	$(hide) $(MAKE) -C $(WL18XX_KM_BUILD_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) KLIB_BUILD=$(KERNEL_BUILD_DIR)
	$(ACP) $(WL18XX_KM_BUILD_OUTPUT) $(WL18XX_KM_OUT_DIR)

$(WL18XX_KM_OUT_DIR):
	$(hide) mkdir -p $@

# It is not clear how to build an external kernel module where the build output
# is in a different direction from the source.  As such, copy the source files
# to the desired build directory and build in-place there...sigh!
# We need to use regular 'cp' rather '$(ACP)' to maintain executable permissions
# on some of the build-scripts.
$(WL18XX_KM_BUILD_DIR)/%: $(WL18XX_KM_SRC_DIR)/%
	$(hide) mkdir -p $(@D)
	$(hide) cp $< $@

clean-wl18xx-km:
	$(hide) -rm -rf $(WL18XX_KM_OUTPUT_FILES)
	$(hide) -rm -rf $(WL18XX_KM_BUILD_DIR)

endif # pepper
