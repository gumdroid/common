.phony: sgx-km clean-sgx-km
SGX_KM_SRC_DIR := $(abspath $(TOP)/device/gumstix/common/sgx/km)
SGX_KM_BUILD_DIR := $(abspath $(TARGET_OUT_INTERMEDIATES)/SGX_OBJ)

# We can't use a yet-to-be determined /lib/modules path as a make
# pre-requisite so install the modules to a known location in the output
# file system and manually insmod them.
SGX_SRC_FILES := $(SGX_KM_SRC_DIR)/echo.c $(SGX_KM_SRC_DIR)/Makefile
SGX_BUILD_FILES := $(SGX_KM_BUILD_DIR)/echo.c $(SGX_KM_BUILD_DIR)/Makefile
SGX_OUTPUT_FILE := $(TARGET_OUT)/etc/echo.ko

# It is not clear how to build an external kernel module where the build output
# is in a different direction from the source.  As such, copy the source files
# to the desired build directory and build in-place there...sigh!
sgx-km $(SGX_OUTPUT_FILE): $(SGX_BUILD_FILES) $(linux) | $(SGX_KM_BUILD_DIR)
	$(hide) $(MAKE) -C $(KERNEL_BUILD_DIR) M=$(SGX_KM_BUILD_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX)
	$(hide) $(ACP) $(SGX_KM_BUILD_DIR)/echo.ko $(SGX_OUTPUT_FILE)

$(SGX_BUILD_FILES): $(SGX_SRC_FILES) | $(SGX_KM_BUILD_DIR)
	$(hide) $(ACP) $(SGX_SRC_FILES) $(SGX_KM_BUILD_DIR)

clean-sgx-km:
	$(hide) -rm -rf $(SGX_OUTPUT_FILE)
	$(hide) -$(MAKE) O=$(KERNEL_BUILD_DIR) -C $(KERNEL_SOURCE_DIR) M=$(SGX_KM_SRC_DIR) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(KERNEL_TOOLCHAIN_PREFIX) clean

$(SGX_KM_BUILD_DIR):
	$(hide) mkdir -p $@

$(TARGET_OUT)/etc/canary: $(SGX_OUTPUT_FILE)
