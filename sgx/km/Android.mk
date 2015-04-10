.PHONY: sgx-km clean-sgx-km
SGX_KM_SRC_DIR := $(abspath $(TOP)/hardware/ti/sgx)
SGX_KM_BUILD_DIR := $(abspath $(TARGET_OUT_INTERMEDIATES)/SGX_OBJ)
SGX_KM_OUT_DIR := $(TARGET_OUT)/etc

SGX_KM_SRC_FILES := $(shell find $(SGX_KM_SRC_DIR) -type f)
SGX_KM_BUILD_FILES := $(patsubst $(SGX_KM_SRC_DIR)/%,$(SGX_KM_BUILD_DIR)/%,$(SGX_KM_SRC_FILES))
SGX_KM_BUILD_OUTPUT := $(SGX_KM_BUILD_DIR)/pvrsrvkm.ko $(SGX_KM_BUILD_DIR)/omaplfb.ko
SGX_KM_OUTPUT_FILES := $(SGX_KM_OUT_DIR)/pvrsrvkm.ko $(SGX_KM_OUT_DIR)/omaplfb.ko

# Hook onto the 'canary' target
# use an intermediate as we've got multiple build outputs
# http://stackoverflow.com/questions/2973445/gnu-makefile-rule-generating-a-few-targets-from-a-single-source-file
$(TARGET_OUT)/etc/canary sgx-km $(SGX_KM_OUTPUT_FILES): sgx-km-output.intermediate

.INTERMEDIATE: sgx-km-output.intermediate
# build and copy output
sgx-km-output.intermediate: $(SGX_KM_BUILD_FILES) $(INSTALLED_KERNEL_TARGET) $(ACP) | $(SGX_KM_OUT_DIR)
	$(hide) rm -f $(SGX_KM_BUILD_OUTPUT)
	$(hide) unset OUT && make -C $(SGX_KM_BUILD_DIR) -f Makefile.KM.Android buildkernel OMAPES=$(OMAPES) GRAPHICS_INSTALL_DIR=$(SGX_KM_BUILD_DIR) ANDROID_ROOT_DIR=$(abspath $(TOP)) KERNEL_INSTALL_DIR=$(KERNEL_BUILD_DIR) KERNELSRC=$(KERNEL_SOURCE_DIR)
	$(hide) $(ACP) $(SGX_KM_BUILD_OUTPUT) $(SGX_KM_OUT_DIR)

$(SGX_KM_OUT_DIR):
	$(hide) mkdir -p $@

# It is not clear how to build an external kernel module where the build output
# is in a different direction from the source.  As such, copy the source files
# to the desired build directory and build in-place there...sigh!
$(SGX_KM_BUILD_DIR)/%: $(SGX_KM_SRC_DIR)/% $(ACP)
	$(hide) mkdir -p $(@D)
	$(hide) $(ACP) $< $@

clean-sgx-km:
	$(hide) -rm -rf $(SGX_KM_OUTPUT_FILES)
	$(hide) -rm -rf $(SGX_KM_BUILD_DIR)

