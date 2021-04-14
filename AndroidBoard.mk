LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Copy additional target-specific files
#----------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE       := gpio-keys.kl
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_KEYLAYOUT)
include $(BUILD_PREBUILT)

# Build the buildtools.zip package.
# It is a package consisting of build tools (like java jdk, build.sh, test-keys),
# that is further useful for post-make standalone image creation (like for super.img).
BUILD_IMAGE_STANDALONE_SCRIPT := build_image_standalone.py
BUILD_IMAGE_STANDALONE_SCRIPT_PATH := vendor/qcom/opensource/core-utils/build/$(BUILD_IMAGE_STANDALONE_SCRIPT)
INTERNAL_BUILDTOOLS_PACKAGE_FILES := \
  build/make/target/product/security \
  vendor/qcom/opensource/core-utils/build/build.sh \
  $(BUILD_IMAGE_STANDALONE_SCRIPT_PATH)

# Pick the default java jdk used by build system
INTERNAL_BUILDTOOLS_PACKAGE_JAVA_PREBUILT := $(JAVA_HOME)

BUILT_BUILDTOOLS_PACKAGE_NAME := buildtools.zip
BUILT_BUILDTOOLS_PACKAGE := $(PRODUCT_OUT)/$(BUILT_BUILDTOOLS_PACKAGE_NAME)
$(BUILT_BUILDTOOLS_PACKAGE): PRIVATE_ZIP_ROOT := $(call intermediates-dir-for,PACKAGING,buildtools)/buildtools
$(BUILT_BUILDTOOLS_PACKAGE): PRIVATE_BUILDTOOLS_PACKAGE_FILES := $(INTERNAL_BUILDTOOLS_PACKAGE_FILES)
$(BUILT_BUILDTOOLS_PACKAGE): PRIVATE_BUILDTOOLS_PACKAGE_FILES_JAVA_PREBUILT := $(INTERNAL_BUILDTOOLS_PACKAGE_JAVA_PREBUILT)
$(BUILT_BUILDTOOLS_PACKAGE): $(INTERNAL_BUILDTOOLS_PACKAGE_FILES) $(INTERNAL_BUILDTOOLS_PACKAGE_JAVA_PREBUILT)
$(BUILT_BUILDTOOLS_PACKAGE): $(SOONG_ZIP)
	@echo "Package build tools: $@"
	rm -rf $@ $(PRIVATE_ZIP_ROOT)
	mkdir -p $(dir $@) $(PRIVATE_ZIP_ROOT)
	$(call copy-files-with-structure,$(PRIVATE_BUILDTOOLS_PACKAGE_FILES),,$(PRIVATE_ZIP_ROOT))
	$(call copy-files-with-structure,$(PRIVATE_BUILDTOOLS_PACKAGE_FILES_JAVA_PREBUILT),$(SOURCE_ROOT)/,$(PRIVATE_ZIP_ROOT))
	echo "$(patsubst $(SOURCE_ROOT)/%,%,$(PRIVATE_BUILDTOOLS_PACKAGE_FILES_JAVA_PREBUILT))" > $(PRIVATE_ZIP_ROOT)/JAVA_HOME.txt
	$(SOONG_ZIP) -o $@ -C $(PRIVATE_ZIP_ROOT) -D $(PRIVATE_ZIP_ROOT)

droidcore: $(BUILT_BUILDTOOLS_PACKAGE)
$(call dist-for-goals,droidcore,$(BUILT_BUILDTOOLS_PACKAGE):buildtools/$(BUILT_BUILDTOOLS_PACKAGE_NAME))
$(call dist-for-goals,droidcore,$(BUILD_IMAGE_STANDALONE_SCRIPT_PATH):buildtools/$(BUILD_IMAGE_STANDALONE_SCRIPT))
# -- end buildtools.zip.

#----------------------------------------------------------------------
# Configs common to AndroidBoard.mk for all targets
#----------------------------------------------------------------------
include vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk

#create firmware directory for qssi
$(shell  mkdir -p $(TARGET_OUT_VENDOR)/firmware)

# override default make with prebuilt make path (if any)
ifneq (, $(wildcard $(shell pwd)/prebuilts/build-tools/linux-x86/bin/make))
   MAKE := $(shell pwd)/prebuilts/build-tools/linux-x86/bin/$(MAKE)
endif
