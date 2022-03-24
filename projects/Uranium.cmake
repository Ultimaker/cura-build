# Copyright (c) 2022 Ultimaker B.V.
# cura-build is released under the terms of the AGPLv3 or higher.

find_package(PyQt 6.2 REQUIRED)
find_package(SciPy 1.7.0 REQUIRED)

GetFromEnvironmentOrCache(
        NAME
            URANIUM_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for Uranium")

GetFromEnvironmentOrCache(
        NAME
            CURA_NO_INSTALL_PLUGINS
        DESCRIPTION
            "A list of plugins to exclude from installation, should be separated by ','.")

ExternalProject_Add(Uranium
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG origin/${URANIUM_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
        -DPython_SITELIB_LOCAL=${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}/site-packages/
        -DUM_NO_INSTALL_PLUGINS=${CURA_NO_INSTALL_PLUGINS})

SetProjectDependencies(TARGET Uranium)