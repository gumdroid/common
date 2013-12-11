LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := mkandroidsd
LOCAL_SRC_FILES := mkandroidsd.sh
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_IS_HOST_MODULE := true

include $(BUILD_PREBUILT)
