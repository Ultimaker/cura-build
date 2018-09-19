#!/usr/bin/env bash
#
# This script modifies all ELF files in the given directory to have RPATH
# '$ORIGIN:$ORIGIN/../lib' before they are packed into an AppImage.
#
# LD_LIBRARY_PATH should not be set in the starting script or there can be
# conflicts between system libraries and the packaged ones.
#

PACKAGE_DIR="$1"

pushd "${PACKAGE_DIR}" > /dev/null

all_files="$(find . -type f)"
for filename in ${all_files}
do
    # Skip files that don't exist
    if [ ! -f "${filename}" ]; then
        continue
    fi
    # Look for ELFs only
    is_elf="$(file -b "${filename}" | grep '^ELF')"
    if [ -z "${is_elf}" ]; then
        continue
    fi

    # Change rpath.
    # If a RUNPATH has already been set in the ELF, we need to remove it first
    # or set-rpath will be setting RUNPATH instead of RPATH, even if the flag
    # --force-rpath is given.
    patchelf --remove-rpath "${filename}"
    patchelf --force-rpath --set-rpath '$ORIGIN:$ORIGIN/../lib' "${filename}"
    echo "RPATH set for ${filename}"
done

popd > /dev/null
