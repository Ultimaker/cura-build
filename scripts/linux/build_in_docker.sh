#!/bin/bash
#
# This script is used in the docker container to create a Cura AppImage.
#

set -e

# Get where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${SCRIPT_DIR}/../.."

# Make sure that cura-build-environment is present
if [[ -z "${CURA_BUILD_ENV_PATH}" ]]; then
    echo "CURA_BUILD_ENV_PATH is not defined. Cannot find the installed cura build environment."
    exit 1
fi

# Make sure that a directory for saving the resulting AppImage exists
CURA_APPIMAGES_OUTPUT_DIR="${CURA_APPIMAGES_OUTPUT_DIR:-/home/ultimaker/appimages}"
if [[ ! -d "${CURA_APPIMAGES_OUTPUT_DIR}" ]]; then
    mkdir -p "${CURA_APPIMAGES_OUTPUT_DIR}"
fi

# Set up Cura build configuration in environment variables
export CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR:-0}"
export CURA_VERSION_MINOR="${CURA_VERSION_MINOR:-0}"
export CURA_VERSION_PATCH="${CURA_VERSION_PATCH:-0}"
export CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA:-}"

export CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT:-https://api.ultimaker.com}"
export CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION:-1}"
export CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT:-https://account.ultimaker.com}"

# Set up development environment variables
source /opt/rh/devtoolset-7/enable
export PATH="${CURA_BUILD_ENV_PATH}/bin:${PATH}"
export PKG_CONFIG_PATH="${CURA_BUILD_ENV_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Create AppImage
cmake3 "${ROOT_DIR}" \
    -DCMAKE_PREFIX_PATH="${CURA_BUILD_ENV_PATH}" \
    -DCURA_VERSION_MAJOR="${CURA_VERSION_MAJOR}" \
    -DCURA_VERSION_MINOR="${CURA_VERSION_MINOR}" \
    -DCURA_VERSION_PATCH="${CURA_VERSION_PATCH}" \
    -DCURA_VERSION_EXTRA="${CURA_VERSION_EXTRA}" \
    -DCURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT}" \
    -DCURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION}" \
    -DCURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT}" \
    -DSIGN_PACKAGE=OFF
make
make package

# Copy the appimage to the output directory
chmod a+x Cura-*.AppImage
cp Cura-*.AppImage "${CURA_APPIMAGES_OUTPUT_DIR}/"
