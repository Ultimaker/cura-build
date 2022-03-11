project(cura-build)

cmake_minimum_required(VERSION 3.18)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

option(BUILD_OFFLINE "Build offline (use target 'update' to update sources)." OFF)

if(BUILD_OFFLINE)
    set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED 1)
endif()

include(ExternalProject)
include(GNUInstallDirs)

# find_package(CuraBuildEnvironment)
include(BuildPlatformDetection)
include(GetFromEnvironmentOrCache)
include(SetProjectDependencies)

option(BUILD_PACKAGE "Create a package with the build of Cura" ON)
option(SIGN_PACKAGE "Perform signing of the created package. Implies BUILD_PACKAGE" ON)

set(CURA_BUILDTYPE          "" CACHE STRING "Build type of Cura, eg. 'testing'")
set(CURA_NO_INSTALL_PLUGINS "" CACHE STRING "A list of plugins to exclude from installation, should be separated by ';'.")

if(SIGN_PACKAGE)
    set(BUILD_PACKAGE ON)
endif()

if(WIN32)
    if(BUILD_PACKAGE)
        # Cura MSI product GUID and upgrade GUID
        if(NOT DEFINED CURA_MSI_PRODUCT_GUID)
            message(SEND_ERROR "CURA_MSI_PRODUCT_GUID must be provided.")
        endif()
        if(NOT DEFINED CURA_MSI_UPGRADE_GUID)
            message(SEND_ERROR "CURA_MSI_UPGRADE_GUID must be provided.")
        endif()
    endif()
endif()

set(EXTERNALPROJECT_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/inst)

GetFromEnvironmentOrCache(FDMMATERIALS_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for fdm_materials")
GetFromEnvironmentOrCache(CURABINARYDATA_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for cura-binary-data")
GetFromEnvironmentOrCache(CURAENGINE_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for CuraEngine")
GetFromEnvironmentOrCache(URANIUM_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for Uranium")
GetFromEnvironmentOrCache(CURA_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for Cura")
GetFromEnvironmentOrCache(LIBCHARON_BRANCH_OR_TAG "master" STRING "The name of the tag or branch to build for libCharon")

GetFromEnvironmentOrCache(CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS "ON" STRING "Whether to enable extra compiler optimization flags for CuraEngine")

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


if(NOT DEFINED Python_VERSION)
    set(Python_VERSION
            3.10
            CACHE STRING "Python Version" FORCE)
    message(STATUS "Setting Python version to ${Python_VERSION}. Set Python_VERSION if you want to compile against an other version.")
endif()
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
