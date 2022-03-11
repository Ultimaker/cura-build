#Copyright (c) 2022 Ultimaker B.V.
#cura-build is released under the terms of the AGPLv3 or higher.

GetFromEnvironmentOrCache(
        NAME
            LIBCHARON_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for libCharon")

# Ensure we're linking to our previously built Python version.
if(WIN32)
    set(pylib_cmake_command ${CMAKE_COMMAND})
else()
    include(${CMAKE_SOURCE_DIR}/cmake/Python.cmake)
    set(pylib_cmake_command PATH=${CMAKE_PREFIX_PATH}/bin/:$ENV{PATH} LD_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib/ PYTHONPATH=${Python_SITEARCH}:${CMAKE_PREFIX_PATH}/lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}:${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}/site-packages/ ${CMAKE_COMMAND})
endif()

ExternalProject_Add(libCharon
    GIT_REPOSITORY https://github.com/Ultimaker/libCharon
    GIT_TAG origin/${LIBCHARON_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_COMMAND ${pylib_cmake_command}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DCURA_PYTHON_VERSION=${Python_VERSION_MAJOR}.${Python_VERSION_MINOR}
)

SetProjectDependencies(TARGET libCharon)

add_dependencies(update libCharon-update)
