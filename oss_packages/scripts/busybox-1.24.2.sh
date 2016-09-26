#!/bin/sh

SCRIPTSDIR=$(dirname $0)
HELPERSDIR="${SCRIPTSDIR}/helpers"
TOPDIR=$(realpath ${SCRIPTSDIR}/../..)

. ${TOPDIR}/scripts/common_settings.sh
. ${HELPERSDIR}/functions.sh

PKG_DIR="busybox-1.24.2"
PKG_ARCHIVE_FILE="${PKG_DIR}.tar.bz2"
PKG_DOWNLOAD="https://busybox.net/downloads/${PKG_ARCHIVE_FILE}"
PKG_CHECKSUM="2eaae519cac1143bcf583636a745381f"

PKG_ARCHIVE="${DOWNLOADS_DIR}/${PKG_ARCHIVE_FILE}"
PKG_SRC_DIR="${SOURCES_DIR}/${PKG_DIR}"
PKG_BUILD_DIR="${BUILD_DIR}/${PKG_DIR}"
PKG_INSTALL_DIR="${PKG_BUILD_DIR}/install"


if [ "${RESCUE}" = "1" ] ; then
    BBOX_BUILD_DIR="${PKG_BUILD_DIR}/build/rescue"
else
    BBOX_BUILD_DIR="${PKG_BUILD_DIR}/build/system"
fi

configure()
{
    cd "${PKG_BUILD_DIR}"
    make ${M3_MAKEFLAGS} V=1 O="${BBOX_BUILD_DIR}" CONFIG_EXTRA_CFLAGS="${M3_CFLAGS} -I${STAGING_INCLUDE}" CONFIG_EXTRA_LDFLAGS="${M3_LDFLAGS} -L${STAGING_LIB}" AR="${AR}" RANLIB="${RANLIB}" NM="${NM}" CROSS_COMPILE=${M3_CROSS_COMPILE} oldconfig
}

menuconfig()
{
    cd "${PKG_BUILD_DIR}"
    make ${M3_MAKEFLAGS} V=1 O="${BBOX_BUILD_DIR}" CONFIG_EXTRA_CFLAGS="${M3_CFLAGS} -I${STAGING_INCLUDE}" CONFIG_EXTRA_LDFLAGS="${M3_LDFLAGS} -L${STAGING_LIB}" AR="${AR}" RANLIB="${RANLIB}" NM="${NM}" CROSS_COMPILE=${M3_CROSS_COMPILE} menuconfig
    DST_FILE=$(echo "${BBOX_BUILD_DIR}/.config" | sed "s#${BUILD_DIR}#${SOURCES_DIR}#")
    cp -a "${BBOX_BUILD_DIR}/.config" "${DST_FILE}"
}

compile()
{
    copy_overlay
    cd "${PKG_BUILD_DIR}"
    make ${M3_MAKEFLAGS} V=1 O="${BBOX_BUILD_DIR}" CONFIG_EXTRA_CFLAGS="${M3_CFLAGS} -I${STAGING_INCLUDE}" CONFIG_EXTRA_LDFLAGS="${M3_LDFLAGS} -L${STAGING_LIB}" AR="${AR}" RANLIB="${RANLIB}" NM="${NM}" CROSS_COMPILE=${M3_CROSS_COMPILE} install || exit_failure "failed to build ${PKG_DIR}"
}

install_staging()
{
    mkdir "${STAGING_DIR}/bin/"
    cp "${BBOX_BUILD_DIR}/busybox" "${STAGING_DIR}/bin/"
    cp "${BBOX_BUILD_DIR}/busybox.links" "${STAGING_DIR}/bin/"
}

uninstall_staging()
{
    rm -vf "${STAGING_DIR}/bin/busybox"
    rm -vf "${STAGING_DIR}/bin/busybox.links"
}

. ${HELPERSDIR}/call_functions.sh
