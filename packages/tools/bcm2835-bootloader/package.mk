# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bcm2835-bootloader"
PKG_VERSION="5476720d52cf579dc1627715262b30ba1242525e"
PKG_SHA256="91430d6b50cd85e4cab0bd9ca12967a5f08b18b43ff4d9fed65676a932d7d302"
PKG_ARCH="arm aarch64"
PKG_LICENSE="nonfree"
PKG_SITE="http://www.broadcom.com"
PKG_URL="${DISTRO_SRC}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain linux bcmstat"
PKG_LONGDESC="bcm2835-bootloader: Tool to create a bootable kernel for RaspberryPi"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
    cp -PRv LICENCE* ${INSTALL}/usr/share/bootloader
    case "${DEVICE}" in
      RPi4*)
        cp -PRv fixup4x.dat ${INSTALL}/usr/share/bootloader/fixup.dat
        cp -PRv start4x.elf ${INSTALL}/usr/share/bootloader/start.elf
        ;;
      RPi5)
        ;;
      *)
        cp -PRv bootcode.bin ${INSTALL}/usr/share/bootloader
        cp -PRv fixup_x.dat ${INSTALL}/usr/share/bootloader/fixup.dat
        cp -PRv start_x.elf ${INSTALL}/usr/share/bootloader/start.elf
        ;;
    esac

    find_file_path bootloader/update.sh ${PKG_DIR}/files/update.sh && cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader

    if find_file_path bootloader/canupdate.sh; then
      cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
      sed -e "s/@PROJECT@/${DEVICE:-${PROJECT}}/g" \
          -i ${INSTALL}/usr/share/bootloader/canupdate.sh
    fi

    find_file_path config/distroconfig.txt ${PKG_DIR}/files/distroconfig.txt && cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    find_file_path config/distroconfig-composite.txt ${PKG_DIR}/files/distroconfig-composite.txt && cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    find_file_path config/config.txt ${PKG_DIR}/files/config.txt && cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
    if [ "${DEVICE}" = "RPiZero-GPiCase" -o "${DEVICE}" = "RPiZero2-GPiCase" ]; then
      find_file_path config/distroconfig.gpi2w.txt ${PKG_DIR}/files/distroconfig.gpi2w.txt && cp -PRv ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
      sed -i '/include distroconfig.txt/a #include distroconfig.gpi2w.txt' ${INSTALL}/usr/share/bootloader/config.txt
    fi

    if [ "${DISTRO}" = "Lakka" ]; then
      echo "disable_splash=1" >> ${INSTALL}/usr/share/bootloader/distroconfig.txt
      echo "dtparam=audio=on" >> ${INSTALL}/usr/share/bootloader/distroconfig.txt
      echo "hdmi_max_pixel_freq:0=200000000" >> ${INSTALL}/usr/share/bootloader/distroconfig.txt
      echo "hdmi_max_pixel_freq:1=200000000" >> ${INSTALL}/usr/share/bootloader/distroconfig.txt
      echo "force_turbo=0" >> ${INSTALL}/usr/share/bootloader/config.txt
    fi
}
