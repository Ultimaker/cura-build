#!/bin/bash
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
ROOT_DIR="${SCRIPT_DIR}/.."

# Cura release configurations
CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR:-0}"
CURA_VERSION_MINOR="${CURA_VERSION_MINOR:-0}"
CURA_VERSION_PATCH="${CURA_VERSION_PATCH:-0}"
CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA:-}"
CURA_BUILD_NAME="${CURA_BUILD_NAME:-master}"

CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT:-https://api.ultimaker.com}"
CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION:-1}"
CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT:-https://account.ultimaker.com}"

# Docker image to use for building the AppImage
cura_build_env_image="cura-build-env:centos7"

pushd "${ROOT_DIR}" > /dev/null

# Prepare the "appimages" directory
mkdir -p appimages

# Run docker to create the AppImage
#
# Environment variables:
#  - CURA_APPIMAGES_OUTPUT_DIR : Where AppImages will be put inside docker container
#
docker run \
  --name cura-builder \
  -it --rm \
  --volume "$(pwd)":/home/ultimaker/src \
  --env CURA_APPIMAGES_OUTPUT_DIR=/home/ultimaker/src/appimages \
  --env CURA_VERSION_MAJOR="${CURA_VERSION_MAJOR}" \
  --env CURA_VERSION_MINOR="${CURA_VERSION_MINOR}" \
  --env CURA_VERSION_PATCH="${CURA_VERSION_PATCH}" \
  --env CURA_VERSION_EXTRA="${CURA_VERSION_EXTRA}" \
  --env CURA_BUILD_NAME="${CURA_BUILD_NAME}" \
  --env CURA_CLOUD_API_ROOT="${CURA_CLOUD_API_ROOT}" \
  --env CURA_CLOUD_API_VERSION="${CURA_CLOUD_API_VERSION}" \
  --env CURA_CLOUD_ACCOUNT_API_ROOT="${CURA_CLOUD_ACCOUNT_API_ROOT}" \
  "${cura_build_env_image}" \
  /home/ultimaker/src/scripts/build_in_docker.sh
