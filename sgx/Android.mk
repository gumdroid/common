LOCAL_PATH:= $(call my-dir)

ifdef OMAPES

include $(CLEAR_VARS)
LOCAL_MODULE := sgx
.phony: sgx clean-sgx

SGX_SOURCE_PATH := $(abspath $(TOP)/hardware/ti/sgx)

# both the kernel and the root file system need to be in place
sgx: droid linux
	unset OUT
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES)
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) install

clean-sgx:
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) clean

# sgx adds files to the system directory...therefore we'd need to rebuild the systemtarball
systemtarball: sgx

endif # OMAPES
