LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := canary
LOCAL_SRC_FILES := canary.txt
LOCAL_MODULE_CLASS := ETC

include $(BUILD_PREBUILT)
