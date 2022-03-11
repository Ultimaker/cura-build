# Copyright 2022 Ultimaker
project(cura-build)

cmake_minimum_required(VERSION 3.18)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(ExternalProject)
include(GNUInstallDirs)

include(GetFromEnvironmentOrCache)
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

GetFromEnvironmentOrCache(
        NAME
            BUILD_PACKAGE
        DEFAULT
            ON
        DESCRIPTION
            "Create a package with the build of Cura"
        BOOL)
GetFromEnvironmentOrCache(
        NAME
            SIGN_PACKAGE
        DEFAULT
            ON
        DESCRIPTION
            "Create a package with the build of Cura"
        BOOL)

if(SIGN_PACKAGE)
    set(BUILD_PACKAGE ON)
endif()

if(WIN32)
    if(BUILD_PACKAGE)
        # Cura MSI product GUID and upgrade GUID
        GetFromEnvironmentOrCache(
                NAME
                    CURA_MSI_PRODUCT_GUID
                DESCRIPTION
                    "MSI product GUID"
                REQUIRED)
        GetFromEnvironmentOrCache(
                NAME
                    CURA_MSI_UPGRADE_GUID
                DESCRIPTION
                    "MSI upgrade GUID"
                REQUIRED)
    endif()
endif()

GetFromEnvironmentOrCache(
        NAME
            FDMMATERIALS_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for fdm_materials")
GetFromEnvironmentOrCache(
        NAME
            CURABINARYDATA_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for cura-binary-data")
GetFromEnvironmentOrCache(
        NAME
            CURAENGINE_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for CuraEngine")
GetFromEnvironmentOrCache(
        NAME
            LIBCHARON_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for libCharon")
GetFromEnvironmentOrCache(
        NAME
            CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS
        DEFAULT
            ON
        DESCRIPTION
            "Whether to enable extra compiler optimization flags for CuraEngine"
        BOOL)
GetFromEnvironmentOrCache(
        NAME
            EXTRA_REPOSITORIES
        DESCRIPTION
            "Extra repositories to install. Expected to have a CMake based build system. Format is (<project name> <git URL> <cmake configuration options>\;)*")
GetFromEnvironmentOrCache(
        NAME
            CURA_EXTRA_PROJECTS_DIR
        DESCRIPTION
            "Directory where extra projects to build are located.")

# Build projects step
add_custom_target(projects ALL COMMENT "Building Projects...")

file(GLOB _projects projects/*.cmake)
if(NOT CURA_EXTRA_PROJECTS_DIR STREQUAL "")
    file(GLOB _extra_projects ${CURA_EXTRA_PROJECTS_DIR}/*.cmake)
    list(APPEND _projects ${_extra_projects})
endif()

add_custom_target(update COMMENT "Updating Projects...")

foreach(_project ${_projects})
    # Go through all files in projects/ and include them. The project files should define
    # targets for the actual projects. In addition, these files are expected to define any
    # packages they depend on with find_package and any other projects they depend on as
    # dependencies of the target(s). Project files are free to define multiple targets though
    # they should only define targets relevant for that project.
    include(${_project})
endforeach()


ProcessProjectDependencies(TARGET projects)

# Create package step
if(BUILD_PACKAGE)
    add_custom_target(packaging ALL DEPENDS projects COMMENT "Packaging Projects...")

    if(WIN32)
        include(packaging/windows.cmake)
    elseif(APPLE)
        include(packaging/osx.cmake)
    elseif(LINUX)
        include(packaging/linux.cmake)
    else()
        message(STATUS "Do not know how to build an executable for the current platform! You will have to create it manually.")
    endif()
endif()

# Sign packages step
if(SIGN_PACKAGE)
    add_custom_target(signing ALL DEPENDS packaging COMMENT "Signing Package...")

    if(WIN32)
        include(signing/windows.cmake)
    elseif(APPLE)
        include(signing/osx.cmake)
    elseif(LINUX)
        include(signing/linux.cmake)
    else()
        message(STATUS "Do not know how to sign the executable for the current platform! You will need to perform signing manually.")
    endif()
endif()
