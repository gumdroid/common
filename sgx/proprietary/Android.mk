LOCAL_PATH := $(call my-dir)

ifdef OMAPES
_base_path := $(OMAPES)

# install the pre-built user-space libraries and executables
define _add-sgx-vendor-lib
include $$(CLEAR_VARS)
LOCAL_MODULE := $(basename $(notdir $1))
LOCAL_SRC_FILES := $(_base_path)/$(notdir $1)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX := .so
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_PATH := $$(TARGET_OUT_VENDOR)/$(dir $1)
include $$(BUILD_PREBUILT)
endef

define _add-sgx-vendor-bin
include $$(CLEAR_VARS)
LOCAL_MODULE := $(basename $(notdir $1))
LOCAL_SRC_FILES := $(_base_path)/$1
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_PATH := $$(TARGET_OUT_VENDOR)/bin
include $$(BUILD_PREBUILT)
endef

define _add-sgx-vendor-apk
include $$(CLEAR_VARS)
LOCAL_MODULE := $(basename $(notdir $1))
LOCAL_SRC_FILES := $(_base_path)/$1
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := PRESIGNED
include $$(BUILD_PREBUILT)
endef

prebuilt_sgx_vendor_libs := \
    lib/egl/libEGL_POWERVR_SGX530_125.so \
    lib/egl/libGLESv1_CM_POWERVR_SGX530_125.so \
    lib/egl/libGLESv2_POWERVR_SGX530_125.so \
    lib/hw/gralloc.omap3.so \
    lib/libeglinfo.so \
    lib/libgles1test1.so \
    lib/libgles2test1.so \
    lib/libglslcompiler.so \
    lib/libIMGegl.so \
    lib/libpvr2d.so \
    lib/libpvrANDROID_WSEGL.so \
    lib/libPVRScopeServices.so \
    lib/libsrv_init.so \
    lib/libsrv_um.so \
    lib/libtestwrap.so \
    lib/libusc.so

prebuilt_sgx_vendor_bins := \
    framebuffer_test \
    hal_blit_test \
    hal_client_test \
    hal_server_test \
    pvrsrvctl \
    pvrsrvinit \
    services_test \
    sgx_flip_test \
    sgx_init_test \
    sgx_render_flip_test \
    testwrap \
    texture_benchmark

prebuilt_sgx_vendor_apks := \
    eglinfo.apk \
    gles1test1.apk \
    gles2test1.apk \
    launcher.apk

# The original install.sh file calls out
#  - sgx_blit_test
#  - sgx_clipblit_test
#  - pvr2d_test
#  - hwcomposer.omap3.so
# but they aren't found. Oppositely, these files are available but not called
# out by the install.sh script---install them just in case:
# - hal_blit_test
# - libtestwrap.so
# - libeglinfo.so
# - libgles1test1.so
# - libgles2test1.so
# There are some .a files---don't bother to install these:
# - libffgen.a
# - libuseasm.a
# - libusp.a
# Also, ignore these jar files as they seem to match the APKs to be installed:
# - common.jar
# - eglinfo.jar
# - gles1test1.jar
# - gles2test1.jar
# - launcher.jar

prebuilt_sgx_modules := $(foreach _file,$(prebuilt_sgx_vendor_libs) $(prebuilt_sgx_vendor_bins) $(prebuilt_sgx_vendor_apks), $(notdir $(basename $(_file))))

include $(CLEAR_VARS)
LOCAL_MODULE := sgx_userspace_blobs
LOCAL_MODULE_OWNER := ti
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(prebuilt_sgx_modules)
include $(BUILD_PHONY_PACKAGE)

$(foreach _file,$(prebuilt_sgx_vendor_libs), \
    $(eval $(call _add-sgx-vendor-lib,$(_file))))
$(foreach _file, $(prebuilt_sgx_vendor_bins), \
  $(eval $(call _add-sgx-vendor-bin,$(_file))))
$(foreach _file, $(prebuilt_sgx_vendor_apks), \
  $(eval $(call _add-sgx-vendor-apk,$(_file))))

prebuilt_sgx_modules :=
prebuilt_sgx_vendor_libs :=
prebuilt_sgx_vendor_bins :=
prebuilt_sgx_vendor_apks :=
_add-sgx-vendor-lib :=
_add-sgx-vendor-bin :=
_add-sgx-vendor-apk :=

endif # OMAPES
