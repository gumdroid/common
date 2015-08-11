#LOCAL_PATH  := device/gumstix/common/samplemedia
#TARGET_PATH := $(TARGET_OUT_DATA)/media/0
#
#PRODUCT_COPY_FILES += \
#        $(LOCAL_PATH)/Pictures/pepper.jpg:$(TARGET_PATH)/Pictures/pepper.jpg
#        $(LOCAL_PATH)/Pictures/gumstix.png:$(TARGET_PATH)/Pictures/gumstix.png
LOCAL_PATH := $(call my-dir)

# install pictures to standard Pictures directory
define _add-samplemedia
include $$(CLEAR_VARS)
LOCAL_MODULE := $(notdir $1)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := DATA
LOCAL_MODULE_PATH := $(TARGET_OUT_DATA)/media/$(dir $1)
LOCAL_SRC_FILES := $1
include $$(BUILD_PREBUILT)
endef

samplemedia_files := \
    Pictures/pepper.jpg \
    Pictures/gumstix.png \
    Movies/big_buck_bunny_480p_VP8_VORBIS_25fps_1900K.WebM \
    Movies/big_buck_bunny_480p_H264_AAC_25fps_1800K.MP4

samplemedia_modules := $(foreach _file, $(samplemedia_files), $(notdir $(_file)))

include $(CLEAR_VARS)
LOCAL_MODULE := samplemedia
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(samplemedia_modules)
include $(BUILD_PHONY_PACKAGE)

$(foreach _file, $(samplemedia_files), \
    $(eval $(call _add-samplemedia,$(_file))))

samplemedia_modules :=
samplemedia_files :=
_add-samplemedia :=
