# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libbpf"
PKG_VERSION="1.4.1"
PKG_SHA256="cc01a3a05d25e5978c20be7656f14eb8b6fcb120bb1c7e8041e497814fc273cb"
PKG_LICENSE="LGPL-2.1"
PKG_SITE="https://github.com/libbpf/libbpf"
PKG_URL="https://github.com/libbpf/libbpf/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain elfutils"
PKG_LONGDESC="libbpf supports building BPF CO-RE-enabled applications"
PKG_TOOLCHAIN="make"

make_target() {
  make BUILD_STATIC_ONLY=1 \
       PREFIX=${SYSROOT_PREFIX}/usr \
       -C src
}

makeinstall_target() {
  make BUILD_STATIC_ONLY=1 \
       PREFIX=${SYSROOT_PREFIX}/usr \
       -C src install
}
