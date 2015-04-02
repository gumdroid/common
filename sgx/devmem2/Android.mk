LOCAL_PATH := $(call my-dir)

# build devmem2 tool
include $(CLEAR_VARS)
LOCAL_SRC_FILES := devmem2.c
LOCAL_MODULE    := devmem2
include $(BUILD_EXECUTABLE)
