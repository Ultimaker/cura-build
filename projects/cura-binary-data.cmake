# Copyright (c) 2022 Ultimaker B.V.
# cura-build is released under the terms of the AGPLv3 or higher.

GetFromEnvironmentOrCache(
        NAME
            CURABINARYDATA_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for cura-binary-data")

ExternalProject_Add(cura-binary-data
    GIT_REPOSITORY https://github.com/ultimaker/cura-binary-data
    GIT_TAG origin/${CURABINARYDATA_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET cura-binary-data DEPENDS Cura)