#!/bin/sh
#
# The following optional environment variables can be set to configure the build:
#  - CURA_TARGET_OSX_VERSION: The minimum OSX version you are targeting
#  - CURA_OSX_SDK_VERSION   : The OSX SDK version to use for compiling
#


# (Optional) Minimum OSX version for deployment
if [ -n "${CURA_TARGET_OSX_VERSION}" ]; then
    echo "Using ${CURA_TARGET_OSX_VERSION} as the minimum OSX version."
    export MACOSX_DEPLOYMENT_TARGET="${CURA_TARGET_OSX_VERSION}"
    export CMAKE_OSX_DEPLOYMENT_TARGET="${CURA_TARGET_OSX_VERSION}"
    export QMAKE_MACOSX_DEPLOYMENT_TARGET="${CURA_TARGET_OSX_VERSION}"

    echo "Set MACOSX_DEPLOYMENT_TARGET to ${MACOSX_DEPLOYMENT_TARGET}"
    echo "Set CMAKE_OSX_DEPLOYMENT_TARGET to ${CMAKE_OSX_DEPLOYMENT_TARGET}"
    echo "Set QMAKE_MACOSX_DEPLOYMENT_TARGET to ${QMAKE_MACOSX_DEPLOYMENT_TARGET}"
fi
# (Optional) OSX SDK version to use
if [ -n "${CURA_OSX_SDK_VERSION}" ]; then
    echo "Using ${CURA_OSX_SDK_VERSION} as the OSX SDK version."
    export CMAKE_OSX_SYSROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX${CURA_OSX_SDK_VERSION}.sdk"

    echo "Set CMAKE_OSX_SYSROOT to ${CMAKE_OSX_SYSROOT}"
fi

export CMAKE_CXX_FLAGS="-stdlib=libc++"
export CXXFLAGS="-stdlib=libc++"

export CC="/Library/Developer/CommandLineTools/usr/bin/clang"
export CXX="/Library/Developer/CommandLineTools/usr/bin/clang++"
