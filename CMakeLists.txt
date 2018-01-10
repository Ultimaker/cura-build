project(cura-build)

cmake_minimum_required(VERSION 2.8.12)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(ExternalProject)
include(GNUInstallDirs)

# find_package(CuraBuildEnvironment)
include(BuildPlatformDetection)
include(GetFromEnvironmentOrCache)
include(SetProjectDependencies)

option(BUILD_PACKAGE "Create a package with the build of Cura" ON)
option(SIGN_PACKAGE "Perform signing of the created package. Implies BUILD_PACKAGE" ON)

if(SIGN_PACKAGE)
    set(BUILD_PACKAGE ON)
endif()

# This should care that our CMAKE_PREFIX_PATH is absolute at the end...
get_filename_component(CMAKE_PREFIX_PATH
                       ${CMAKE_PREFIX_PATH}
                       ABSOLUTE
                       CACHE FORCE)

set(EXTERNALPROJECT_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/inst)

GetFromEnvironmentOrCache(FDMMATERIALS_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for fdm_materials")
GetFromEnvironmentOrCache(CURABINARYDATA_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for cura-binary-data")
GetFromEnvironmentOrCache(CURAENGINE_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for CuraEngine")
GetFromEnvironmentOrCache(URANIUM_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for Uranium")
GetFromEnvironmentOrCache(CURA_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for Cura")

GetFromEnvironmentOrCache(CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS "ON" STRING "Whether to enable extra compiler optimization flags for CuraEngine")

GetFromEnvironmentOrCache(CURA_BUILD_NAME "master" STRING "The build name")
GetFromEnvironmentOrCache(EXTRA_REPOSITORIES "" STRING "Extra repositories to install. Expected to have a CMake based build system. Format is (<project name> <git URL> <cmake configuration options>\;)*")

# Create the version-related variables
GetFromEnvironmentOrCache(CURA_VERSION_MAJOR "0" STRING "Cura Major Version")
GetFromEnvironmentOrCache(CURA_VERSION_MINOR "0" STRING "Cura Minor Version")
GetFromEnvironmentOrCache(CURA_VERSION_PATCH "0" STRING "Cura Patch Version")
GetFromEnvironmentOrCache(CURA_VERSION_EXTRA "${TAG_OR_BRANCH}" STRING "Cura Extra Version Information")

GetFromEnvironmentOrCache(CURA_EXTRA_PROJECTS_DIR "" STRING "Directory where extra projects to build are located.")

set(CURA_VERSION "${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}.${CURA_VERSION_PATCH}")
if(NOT "${CURA_VERSION_EXTRA}" STREQUAL "")
    set(CURA_VERSION "${CURA_VERSION}-${CURA_VERSION_EXTRA}")
endif()

# Build projects step
add_custom_target(projects ALL COMMENT "Building Projects...")

file(GLOB _projects projects/*.cmake)
if(NOT CURA_EXTRA_PROJECTS_DIR STREQUAL "")
    file(GLOB _extra_projects ${CURA_EXTRA_PROJECTS_DIR}/*.cmake)
    list(APPEND _projects ${_extra_projects})
endif()

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
