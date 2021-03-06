#!/bin/sh

# name of directory after extracting the archive in working directory
PKG_DIR="tinyxml2-6.2.0"

# name of the archive in dl directory (use "none" if empty)
PKG_ARCHIVE_FILE="${PKG_DIR}.tar.gz"

# download link for the sources to be stored in dl directory (use "none" if empty)
# PKG_DOWNLOAD="https://github.com/leethomason/tinyxml2/archive/${PKG_ARCHIVE_FILE##*-}"
PKG_DOWNLOAD="https://m3-container.net/M3_Container/oss_packages/${PKG_ARCHIVE_FILE}"

# md5 checksum of archive in dl directory (use "none" if empty)
PKG_CHECKSUM="e9056594463c1ecc4c945f578af0a734"



SCRIPTSDIR=$(dirname $0)
HELPERSDIR="${SCRIPTSDIR}/helpers"
TOPDIR=$(realpath ${SCRIPTSDIR}/../..)
. "${TOPDIR}/scripts/common_settings.sh"
. "${HELPERSDIR}/functions.sh"
PKG_ARCHIVE="${DOWNLOADS_DIR}/${PKG_ARCHIVE_FILE}"
PKG_SRC_DIR="${SOURCES_DIR}/${PKG_DIR}"
PKG_BUILD_DIR="${BUILD_DIR}/${PKG_DIR}"
PKG_INSTALL_DIR="${PKG_BUILD_DIR}/install"

configure()
{
    cd "${PKG_BUILD_DIR}"
    cmake \
        -DCMAKE_C_COMPILER=${M3_CROSS_COMPILE}gcc \
        -DCMAKE_C_FLAGS="${CFLAGS} -fPIC -I${STAGING_INCLUDE} -L${STAGING_LIB}" \
        -DCMAKE_AR=${AR} \
        -DCMAKE_LINKER=${M3_CROSS_COMPILE}ld \
        -DCMAKE_STRIP=${M3_CROSS_COMPILE}strip \
        -DCMAKE_NM=${NM} \
        -DCMAKE_RANLIB=${RANLIB} \
        -DCMAKE_INSTALL_PREFIX="" \
        || exit_failure "failed to configure ${PKG_DIR}"
}

compile()
{
    copy_overlay
    cd "${PKG_BUILD_DIR}"
    make ${M3_MAKEFLAGS} || exit_failure "failed to build ${PKG_DIR}"
    make DESTDIR="${PKG_INSTALL_DIR}" install || exit_failure "failed to install ${PKG_DIR} to ${PKG_INSTALL_DIR}"
}

install_staging()
{
    cd "${PKG_BUILD_DIR}"
    make DESTDIR="${STAGING_DIR}" install || exit_failure "failed to install ${PKG_DIR} to ${STAGING_DIR}"
}

. ${HELPERSDIR}/call_functions.sh
