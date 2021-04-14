#
# Copyright (C) 2021 CygnusOS
#
# SPDX-License-Identifer: Apache-2.0

# Inherit Cygnus common configuration
$(call inherit-product, vendor/cygnus/configs/common.mk)

# Inherit QSSI configurations
$(call inherit-product, device/cygnus/qssi/qssi.mk)

PRODUCT_NAME := cygnus_qssi
PRODUCT_DEVICE := QSSI
PRODUCT_BRAND := Cygnus
PRODUCT_MODEL := Cygnus QSSI for ARM64