#!/bin/bash
#
# This script is used in the docker container to create a Cura AppImage.
#

set -e

# Get where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${SCRIPT_DIR}/../../.."

# Make sure that cura-build-environment is present
if [[ -z "${CURA_BUILD_ENV_PATH}" ]]; then
    echo "CURA_BUILD_ENV_PATH is not defined. Cannot find the installed cura build environment."
    exit 1
fi

# Make sure that a directory for saving the resulting AppImage exists
CURA_BUILD_OUTPUT_DIR="${CURA_BUILD_OUTPUT_DIR:-/home/ultimaker/output}"
if [[ ! -d "${CURA_BUILD_OUTPUT_DIR}" ]]; then
    mkdir -p "${CURA_BUILD_OUTPUT_DIR}"
fi

# Set up Cura build configuration in environment variables
export CURA_BRANCH_OR_TAG="${CURA_BRANCH_OR_TAG:-master}"
export URANIUM_BRANCH_OR_TAG="${URANIUM_BRANCH_OR_TAG:-master}"
export CURAENGINE_BRANCH_OR_TAG="${CURAENGINE_BRANCH_OR_TAG:-master}"
export CURABINARYDATA_BRANCH_OR_TAG="${CURABINARYDATA_BRANCH_OR_TAG:-master}"
export FDMMATERIALS_DATA_BRANCH_OR_TAG="${FDMMATERIALS_BRANCH_OR_TAG:-master}"
export LIBCHARON_BRANCH_OR_TAG="${LIBCHARON_BRANCH_OR_TAG:-master}"

export CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR:-0}"
export CURA_VERSION_MINOR="${CURA_VERSION_MINOR:-0}"
export CURA_VERSION_PATCH="${CURA_VERSION_PATCH:-0}"
export CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA:-}"

export CURA_BUILD_TYPE="${CURA_BUILD_TYPE}"
export CURA_NO_INSTALL_PLUGINS="${CURA_NO_INSTALL_PLUGINS}"

export CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT:-https://api.ultimaker.com}"
export CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION:-1}"
export CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT:-https://account.ultimaker.com}"

export CURA_ENABLE_DEBUG_MODE="${CURA_ENABLE_DEBUG_MODE:-ON}"
export CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS="${CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS:-ON}"

# Set up development environment variables
source /opt/rh/devtoolset-7/enable
export PATH="${CURA_BUILD_ENV_PATH}/bin:${PATH}"
export PKG_CONFIG_PATH="${CURA_BUILD_ENV_PATH}/lib/pkgconfig:${PKG_CONFIG_PATH}"

mkdir "${CURA_BUILD_OUTPUT_DIR}/build"
mkdir "${CURA_BUILD_OUTPUT_DIR}/appimages"

cd "${CURA_BUILD_OUTPUT_DIR}/build"

# Create AppImage
cmake3 "${ROOT_DIR}" \
    -DCMAKE_PREFIX_PATH="${CURA_BUILD_ENV_PATH}" \
    -DCURA_VERSION_MAJOR="${CURA_VERSION_MAJOR}" \
    -DCURA_VERSION_MINOR="${CURA_VERSION_MINOR}" \
    -DCURA_VERSION_PATCH="${CURA_VERSION_PATCH}" \
    -DCURA_VERSION_EXTRA="${CURA_VERSION_EXTRA}" \
    -DCURA_BUILDTYPE="${CURA_BUILD_TYPE}" \
    -DCURA_NO_INSTALL_PLUGINS="${CURA_NO_INSTALL_PLUGINS}" \
    -DCURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT}" \
    -DCURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION}" \
    -DCURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT}" \
    -DSIGN_PACKAGE=OFF
make
make package

# Copy the appimage to the output directory
chmod a+x Ultimaker_Cura-*.AppImage
cp Ultimaker_Cura-*.AppImage "${CURA_BUILD_OUTPUT_DIR}/appimages"
