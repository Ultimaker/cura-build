#!/bin/sh
#
# This scripts builds a Cura AppImage using a docker container. The docker base
# image it uses is "cura-build-env:centos7", which can be created with the
# cura-build-environment repository. The AppImage will be created under the
# directory "appimages", which will be created if it's not present. Note that
# the AppImage being created will not be signed.
#

set -e

# Get where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="${SCRIPT_DIR}/../.."

# Cura release configurations
CURA_BRANCH_OR_TAG="${CURA_BRANCH_OR_TAG:-master}"
URANIUM_BRANCH_OR_TAG="${URANIUM_BRANCH_OR_TAG:-master}"
CURAENGINE_BRANCH_OR_TAG="${CURAENGINE_BRANCH_OR_TAG:-master}"
CURABINARYDATA_BRANCH_OR_TAG="${CURABINARYDATA_BRANCH_OR_TAG:-master}"
FDMMATERIALS_DATA_BRANCH_OR_TAG="${FDMMATERIALS_BRANCH_OR_TAG:-master}"
LIBCHARON_BRANCH_OR_TAG="${LIBCHARON_BRANCH_OR_TAG:-master}"

CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR:-0}"
CURA_VERSION_MINOR="${CURA_VERSION_MINOR:-0}"
CURA_VERSION_PATCH="${CURA_VERSION_PATCH:-0}"
CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA:-}"

CURA_BUILD_TYPE="${CURA_BUILD_TYPE}"
CURA_NO_INSTALL_PLUGINS="${CURA_NO_INSTALL_PLUGINS}"

CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT:-https://api.ultimaker.com}"
CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION:-1}"
CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT:-https://account.ultimaker.com}"

CURA_ENABLE_DEBUG_MODE="${CURA_ENABLE_DEBUG_MODE:-ON}"
CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS="${CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS:-ON}"

if [ -t 0 ]; then
  IS_INTERACTIVE=yes
else
  IS_INTERACTIVE=no
fi

# Docker image to use for building the AppImage
cura_build_env_image="ultimaker/cura-build-environment:centos-latest"

__old_pwd="$(pwd)"
cd "${ROOT_DIR}"

# Prepare the "appimages" directory
mkdir -p appimages

DOCKER_EXTRA_ARGS=""
if [ "${IS_INTERACTIVE}" == "yes" ]; then
  # Add -it so you can do CTRL-C in terminal if you are running in a TTY.
  DOCKER_EXTRA_ARGS="-it ${DOCKER_EXTRA_ARGS}"
fi

# Run docker to create the AppImage
#
# Environment variables:
#  - CURA_APPIMAGES_OUTPUT_DIR : Where AppImages will be put inside docker container
#
docker run \
  ${DOCKER_EXTRA_ARGS} \
  --rm \
  --volume "$(pwd)":/home/ultimaker/src \
  --env CURA_APPIMAGES_OUTPUT_DIR=/home/ultimaker/src/appimages \
  --env CURA_BRANCH_OR_TAG="${CURA_BRANCH_OR_TAG}" \
  --env URANIUM_BRANCH_OR_TAG="${URANIUM_BRANCH_OR_TAG}" \
  --env CURAENGINE_BRANCH_OR_TAG="${CURAENGINE_BRANCH_OR_TAG}" \
  --env CURABINARYDATA_BRANCH_OR_TAG="${CURABINARYDATA_BRANCH_OR_TAG}" \
  --env FDMMATERIALS_DATA_BRANCH_OR_TAG="${FDMMATERIALS_DATA_BRANCH_OR_TAG}" \
  --env LIBCHARON_BRANCH_OR_TAG="${LIBCHARON_BRANCH_OR_TAG}" \
  --env CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR}" \
  --env CURA_VERSION_MINOR="${CURA_VERSION_MINOR}" \
  --env CURA_VERSION_PATCH="${CURA_VERSION_PATCH}" \
  --env CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA}" \
  --env CURA_BUILD_TYPE="${CURA_BUILD_TYPE}" \
  --env CURA_NO_INSTALL_PLUGINS="${CURA_NO_INSTALL_PLUGINS}" \
  --env CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT}" \
  --env CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION}" \
  --env CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT}" \
  --env CURA_ENABLE_DEBUG_MODE="${CURA_ENABLE_DEBUG_MODE}" \
  --env CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS="${CURA_ENABLE_CURAENGINE_EXTRA_OPTIMIZATION_FLAGS}" \
  "${cura_build_env_image}" \
  /home/ultimaker/src/scripts/linux/build_in_docker.sh

cd "${__old_pwd}"
