# Build script for patch

do_companion_tools_patch_get() {
    CT_GetFile "patch-${CT_PATCH_VERSION}"    \
        {http,ftp,https}://ftp.gnu.org/gnu/patch
}

do_companion_tools_patch_extract() {
    CT_Extract "patch-${CT_PATCH_VERSION}"
    CT_DoExecLog ALL chmod -R u+w "${CT_SRC_DIR}/patch-${CT_PATCH_VERSION}"
    CT_Patch "patch" "${CT_PATCH_VERSION}"
}

do_companion_tools_patch_for_build() {
    CT_DoStep EXTRA "Installing patch for build"
    CT_mkdir_pushd "${CT_BUILD_DIR}/build-patch-build"
    do_PATCH_backend host=${CT_BUILD} prefix="${CT_BUILD_COMPTOOLS_DIR}"
    CT_Popd
    CT_EndStep
}

do_companion_tools_patch_for_host() {
    CT_DoStep EXTRA "Installing patch for host"
    CT_mkdir_pushd "${CT_BUILD_DIR}/build-patch-host"
    do_PATCH_backend host=${CT_HOST} prefix="${CT_PREFIX_DIR}"
    CT_Popd
    CT_EndStep
}

do_PATCH_backend() {
    local host
    local prefix

    for arg in "$@"; do
        eval "${arg// /\\ }"
    done

    # Ensure configure gets run using the CONFIG_SHELL as configure seems to
    # have trouble when CONFIG_SHELL is set and /bin/sh isn't bash
    # For reference see:
    # http://www.gnu.org/software/patch/manual/patch.html#CONFIG_005fSHELL
    CT_DoLog EXTRA "Configuring patch"
    CT_DoExecLog CFG ${CONFIG_SHELL} \
    "${CT_SRC_DIR}/patch-${CT_PATCH_VERSION}/configure" \
                     --host="${host}" \
                     --prefix="${prefix}"

    CT_DoLog EXTRA "Building patch"
    CT_DoExecLog ALL make

    CT_DoLog EXTRA "Installing patch"
    CT_DoExecLog ALL make install
}
