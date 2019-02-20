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

# Docker image to use for building the AppImage
cura_build_env_image="cura-build-env:centos7"

pushd "${ROOT_DIR}" > /dev/null

# Prepare the "appimages" directory
mkdir -p appimages

# Run docker to create the AppImage
docker run \
  --name cura-builder \
  -it --rm \
  --volume "$(pwd)":/home/ultimaker/src \
  --env CURA_APPIMAGES_OUTPUT_DIR=/home/ultimaker/src/appimages \
  "${cura_build_env_image}" \
  /home/ultimaker/src/scripts/build_in_docker.sh
