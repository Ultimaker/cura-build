#Copyright (c) 2021 Ultimaker B.V.
#cura-build is released under the terms of the AGPLv3 or higher.

# Ensure we're linking to our previously built Python version.
if(BUILD_OS_LINUX)
    set(pylib_cmake_command PATH=${CMAKE_PREFIX_PATH}/bin/:$ENV{PATH} LD_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib/ PYTHONPATH=${CMAKE_PREFIX_PATH}/lib/python3/dist-packages/:${CMAKE_PREFIX_PATH}/lib/python3.10:${CMAKE_PREFIX_PATH}/lib/python3.10/site-packages/ ${CMAKE_COMMAND})
else()
    set(pylib_cmake_command ${CMAKE_COMMAND})
endif()

ExternalProject_Add(libCharon
    GIT_REPOSITORY https://github.com/Ultimaker/libCharon
    GIT_TAG origin/${LIBCHARON_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_COMMAND ${pylib_cmake_command}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET libCharon)

add_dependencies(update libCharon-update)
