ifdef OMAPES
include $(CLEAR_VARS)
SGX_SOURCE_PATH := $(abspath $(TOP)/hardware/ti/sgx)

.phony: build-sgx clean-sgx

# build it and copy executables; avoid rebuilds if possible so don't reconfig. 
build-sgx: system build-kernel
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES)
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) install

clean-sgx:
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) clean

endif
