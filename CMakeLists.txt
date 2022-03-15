# Copyright 2022 Ultimaker

# Setting the MACOSX_DEPLOYMENT_TARGET needs to be done before the first project() call. Setting this value should also
# take care of the CMAKE_OSX_SYSROOT. The variable is ignored on non-Apple systems.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(GetFromEnvironmentOrCache)
GetFromEnvironmentOrCache(
        NAME
            CMAKE_OSX_DEPLOYMENT_TARGET
        DESCRIPTION
            "Specify the minimum version of the target platform (e.g. macOS or iOS)")

project(cura-build)
cmake_minimum_required(VERSION 3.18)

include(ExternalProject)
include(GNUInstallDirs)
include(SetProjectDependencies)

GetFromEnvironmentOrCache(
        NAME
            BUILD_OFFLINE
        DEFAULT
            OFF
        DESCRIPTION
            "Cura build offline mode, handy for debugging"
        BOOL)
if(BUILD_OFFLINE)
    set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED 1)
endif()

# Build projects step
add_custom_target(projects ALL COMMENT "Building Projects...")

set(_projects
        ${CMAKE_SOURCE_DIR}/projects/Cura.cmake
        ${CMAKE_SOURCE_DIR}/projects/CuraEngine.cmake
        ${CMAKE_SOURCE_DIR}/projects/Uranium.cmake
        ${CMAKE_SOURCE_DIR}/projects/libCharon.cmake
        ${CMAKE_SOURCE_DIR}/projects/fdm_materials.cmake
        )
include(${CMAKE_SOURCE_DIR}/projects/ExtraRepository.cmake)

foreach(_project ${_projects})
    # Go through all files in projects/ and include them. The project files should define
    # targets for the actual projects. In addition, these files are expected to define any
    # packages they depend on with find_package and any other projects they depend on as
    # dependencies of the target(s). Project files are free to define multiple targets though
    # they should only define targets relevant for that project.
    include(${_project})
endforeach()

ProcessProjectDependencies(TARGET projects)
