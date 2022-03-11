# Copyright 2022 Ultimaker
project(cura-build)

cmake_minimum_required(VERSION 3.18)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

option(BUILD_OFFLINE "Build offline (use target 'update' to update sources)." OFF)

include(ExternalProject)
include(GNUInstallDirs)

# find_package(CuraBuildEnvironment)
include(BuildPlatformDetection)
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
GetFromEnvironmentOrCache(
        NAME
            CURA_BUILDTYPE
        DESCRIPTION
            "Build type of Cura, eg. 'testing'")
GetFromEnvironmentOrCache(
        NAME
            CURA_NO_INSTALL_PLUGINS
        DESCRIPTION
            "A list of plugins to exclude from installation, should be separated by ';'.")

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
            EXTERNALPROJECT_INSTALL_PREFIX
        DEFAULT
            ${CMAKE_CURRENT_BINARY_DIR}/install
        DESCRIPTION
            "Location where the External projects need to be installed in")
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
            URANIUM_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for Uranium")
GetFromEnvironmentOrCache(
        NAME
            CURA_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION "The name of the tag or branch to build for Cura")
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

# Create the version-related variables
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_MAJOR
        DESCRIPTION
            "Cura Major Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_MINOR
        DEFAULT
            0
        DESCRIPTION
            "Cura Minor Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_PATCH
        DEFAULT
            0
        DESCRIPTION
            "Cura Patch Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_EXTRA
        DESCRIPTION
            "Cura Extra Version Information")
if(NOT ${CURA_VERSION_EXTRA} STREQUAL "")
    set(CURA_VERSION_EXTRA "-${CURA_VERSION_EXTRA}")
endif()
set(_default_cura_version "${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}.${CURA_VERSION_PATCH}${CURA_VERSION_EXTRA}")
if(${_default_cura_version} VERSION_GREATER 0.0.0)
    set(CURA_VERSION ${_default_cura_version})
endif()
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION
        DESCRIPTION
            "Cura Extra Version Information"
        REQUIRED)

# Build projects step
add_custom_target(projects ALL COMMENT "Building Projects...")

file(GLOB _projects projects/*.cmake)
if(NOT CURA_EXTRA_PROJECTS_DIR STREQUAL "")
    file(GLOB _extra_projects ${CURA_EXTRA_PROJECTS_DIR}/*.cmake)
    list(APPEND _projects ${_extra_projects})
endif()

GetFromEnvironmentOrCache(
        NAME
            Python_VERSION
        DEFAULT
            3.10
        DESCRIPTION
            "Python Version to use"
        REQUIRED)
if(APPLE)
    set(Python_FIND_FRAMEWORK NEVER)
endif()
find_package(Python ${Python_VERSION} EXACT REQUIRED COMPONENTS Interpreter)
message(STATUS "Using Python ${Python_VERSION}")

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

    if(BUILD_OS_WINDOWS)
        include(packaging/windows.cmake)
    elseif(BUILD_OS_OSX)
        include(packaging/osx.cmake)
    elseif(BUILD_OS_LINUX)
        include(packaging/linux.cmake)
    else()
        message(STATUS "Do not know how to build an executable for the current platform! You will have to create it manually.")
    endif()
endif()

# Sign packages step
if(SIGN_PACKAGE)
    add_custom_target(signing ALL DEPENDS packaging COMMENT "Signing Package...")

    if(BUILD_OS_WINDOWS)
        include(signing/windows.cmake)
    elseif(BUILD_OS_OSX)
        include(signing/osx.cmake)
    elseif(BUILD_OS_LINUX)
        include(signing/linux.cmake)
    else()
        message(STATUS "Do not know how to sign the executable for the current platform! You will need to perform signing manually.")
    endif()
endif()
