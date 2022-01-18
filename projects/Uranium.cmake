#Copyright (c) 2021 Ultimaker B.V.
#cura-build is released under the terms of the AGPLv3 or higher.

find_package(PythonInterp 3 REQUIRED)
if(NOT BUILD_OS_WINDOWS)
    # Only ask for Qt5 where it is actually built via cura-build-environment.
    # On Windows we are using PyQt5 to provide our libraries prebuilt.
    #find_package(Qt5 5.15.0 REQUIRED Core Qml Quick Widgets)
endif()
find_package(PyQt 5.15 REQUIRED)
find_package(SciPy 1.2.0 REQUIRED)

# Ensure we're linking to our previously built Python version.
if(BUILD_OS_LINUX)
    set(pylib_cmake_command PATH=${CMAKE_PREFIX_PATH}/bin/:$ENV{PATH} LD_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib/ PYTHONPATH=${CMAKE_PREFIX_PATH}/lib/python3/dist-packages/:${CMAKE_PREFIX_PATH}/lib/python3.10:${CMAKE_PREFIX_PATH}/lib/python3.10/site-packages/ ${CMAKE_COMMAND})
else()
    set(pylib_cmake_command ${CMAKE_COMMAND})
endif()

# WORKAROUND: CMAKE_ARGS itself is a string list with items separated by ';'. Passing a string list that's also
# separated by ';' as an argument via CMAKE_ARGS will make it confused. Converting it to "," and then to ";" is a
# workaround.
string(REPLACE ";" "," _cura_no_install_plugins "${CURA_NO_INSTALL_PLUGINS}")

ExternalProject_Add(Uranium
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG origin/${URANIUM_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_COMMAND ${pylib_cmake_command}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DUM_NO_INSTALL_PLUGINS=${_cura_no_install_plugins}
)

SetProjectDependencies(TARGET Uranium)

add_dependencies(update Uranium-update)
