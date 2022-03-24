#Copyright (c) 2022 Ultimaker B.V.
#cura-build is released under the terms of the AGPLv3 or higher.

GetFromEnvironmentOrCache(
        NAME
            LIBCHARON_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for libCharon")

ExternalProject_Add(libCharon
    GIT_REPOSITORY https://github.com/Ultimaker/libCharon
    GIT_TAG origin/${LIBCHARON_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DPython_SITELIB_LOCAL=${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}/site-packages/
)

SetProjectDependencies(TARGET libCharon)