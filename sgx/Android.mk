ifdef OMAPES

include $(CLEAR_VARS)
LOCAL_MODULE := sgx
.phony: sgx clean-sgx

SGX_SOURCE_PATH := $(abspath $(TOP)/hardware/ti/sgx)

# both the kernel and the root file system need to be in place
sgx: droid linux
	$(hide) -rm $(PRODUCT_OUT)/system.tar.bz2
	$(hide) -rm $(PRODUCT_OUT)/userdata.tar.bz2
	unset OUT
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES)
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) install

clean-sgx:
	$(MAKE) -C $(SGX_SOURCE_PATH) ANDROID_ROOT_DIR=$(realpath $(TOP)) OMAPES=$(OMAPES) clean

# sgx adds files to the system & data directories so we'd need to rebuild the tarballs
systemtarball: sgx
userdatatarball: sgx

endif # OMAPES
