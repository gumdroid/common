LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

# top-level make target
gumstix: mkandroidsd build-uboot build-kernel build-sgx systemtarball userdatatarball uinitrd
