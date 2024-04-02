# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xorg-server"
PKG_VERSION="21.1.11"
PKG_SHA256="1d3dadbd57fb86b16a018e9f5f957aeeadf744f56c0553f55737628d06d326ef"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="https://www.x.org/releases/individual/xserver/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain util-macros font-util xorgproto libpciaccess libX11 libXfont2 libXinerama libxcvt libxshmfence libxkbfile libdrm openssl freetype pixman systemd xorg-launch-helper"
PKG_NEED_UNPACK="$(get_pkg_directory xf86-video-nvidia) $(get_pkg_directory xf86-video-nvidia-legacy)"
PKG_LONGDESC="X.Org Server is the free and open-source implementation of the X Window System display server."

get_graphicdrivers

PKG_MESON_OPTS_TARGET="-Dxorg=true \
                       -Dxephyr=false \
                       -Dxnest=false \
                       -Dxvfb=false \
                       -Dxwin=false \
                       -Dxquartz=false \
                       -Dbuilder_addr=${BUILDER_NAME} \
                       -Dlog_dir="/var/log" \
                       -Dmodule_dir=${XORG_PATH_MODULES} \
                       -Ddefault_font_path="/usr/share/fonts/misc,built-ins" \
                       -Dxdmcp=false \
                       -Dxdm-auth-1=false \
                       -Dsecure-rpc=false \
                       -Dipv6=false \
                       -Dinput_thread=true \
                       -Dxkb_dir=${XORG_PATH_XKB} \
                       -Dxkb_output_dir="/var/cache/xkb" \
                       -Dvendor_name="LibreELEC" \
                       -Dvendor_name_short="LE" \
                       -Dvendor_web="https://libreelec.tv/" \
                       -Dlisten_tcp=false \
                       -Dlisten_unix=true \
                       -Dlisten_local=false \
                       -Dint10=x86emu \
                       -Dpciaccess=true \
                       -Dudev=true \
                       -Dudev_kms=true \
                       -Dhal=false \
                       -Dsystemd_logind=false \
                       -Dvgahw=true \
                       -Ddpms=true \
                       -Dxf86bigfont=false \
                       -Dscreensaver=false \
                       -Dxres=true \
                       -Dxace=false \
                       -Dxselinux=false \
                       -Dxinerama=true \
                       -Dxcsecurity=false \
                       -Dxv=true \
                       -Dxvmc=false \
                       -Ddga=true \
                       -Dlinux_apm=false \
                       -Dlinux_acpi=false \
                       -Dmitshm=true \
                       -Dsha1="libcrypto" \
                       -Ddri2=true \
                       -Ddri3=true \
                       -Ddrm=true \
                       -Dxpbproxy=false \
                       -Dlibunwind=false \
                       -Ddocs=false \
                       -Ddevel-docs=false"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} libepoxy"
  if [ ! "${PROJECT}" = "L4T" ]; then
    PKG_MESON_OPTS_TARGET+=" -Dglx=true \
                             -Ddri1=true \
                             -Dglamor=true"
  else
    PKG_MESON_OPTS_TARGET+=" -Dglx=true \
                             -Ddri1=true \
                             -Dglamor=false"
  fi
else
  PKG_MESON_OPTS_TARGET+=" -Dglx=false \
                           -Ddri1=false \
                           -Dglamor=false"
fi

#if [ "${PROJECT}" = "L4T" ]; then
#  PKG_CONFIGURE_OPTS_TARGET+=" --disable-strip \
#                               --enable-glx-tls \
#                               --enable-aiglx"
#fi

#pre_configure_target() {
# hack to prevent a build error
#  CFLAGS=$(echo ${CFLAGS} | sed -e "s|-O3|-O2|" -e "s|-Ofast|-O2|")
#  LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-O3|-O2|" -e "s|-Ofast|-O2|")
#  if [ "${PROJECT}" = "L4T" ]; then
#    CFLAGS+=" -g"
#  fi
#}

if [ "${COMPOSITE_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libXcomposite"
fi

pre_configure_target() {
  if [ "${PROJECT}" = "L4T" ]; then
    CFLAGS+=" -g"
  fi
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/var/cache/xkb

  mkdir -p ${INSTALL}/usr/lib/xorg
    cp -P ${PKG_DIR}/scripts/xorg-configure ${INSTALL}/usr/lib/xorg
      sed -i -e "s|@NVIDIA_VERSION@|$(get_pkg_version xf86-video-nvidia)|g" ${INSTALL}/usr/lib/xorg/xorg-configure
      sed -i -e "s|@NVIDIA_LEGACY_VERSION@|$(get_pkg_version xf86-video-nvidia-legacy)|g" ${INSTALL}/usr/lib/xorg/xorg-configure

  if [ ! "${OPENGL}" = "no" ]; then
    if [ ! "${PROJECT}" = "L4T" ] || [ ! "${DEVICE}" = "Odin" ]; then
      if [ -f ${INSTALL}/usr/lib/xorg/modules/extensions/libglx.so ]; then
        mv ${INSTALL}/usr/lib/xorg/modules/extensions/libglx.so \
           ${INSTALL}/usr/lib/xorg/modules/extensions/libglx_mesa.so # rename for cooperate with nvidia drivers
        ln -sf /var/lib/libglx.so ${INSTALL}/usr/lib/xorg/modules/extensions/libglx.so
      fi
    fi
  fi

  mkdir -p ${INSTALL}/etc/X11
    if find_file_path config/xorg.conf; then
      cp ${FOUND_PATH} ${INSTALL}/etc/X11
    fi
}

post_install() {
  if [ "${DISTRO}" = "Lakka" ]; then
    sed -i ${INSTALL}/usr/lib/systemd/system/xorg.service \
        -e "s|kodi\.service|retroarch.service|g"
  fi
  enable_service xorg.service
}
