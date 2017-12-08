find_package(PythonInterp 3.5.0 REQUIRED)
if(NOT BUILD_OS_WINDOWS)
    # Only ask for Qt5 where it is actually built via cura-build-environment.
    # On Windows we are using PyQt5 to provide our libraries prebuilt.
    find_package(Qt5 5.6.0 REQUIRED Core Qml Quick Widgets)
endif()
find_package(PyQt 5.6 REQUIRED)
find_package(SciPy 0.17 REQUIRED)

ExternalProject_Add(Uranium
    GIT_REPOSITORY https://github.com/thopiekar/Uranium
    GIT_TAG origin/master-prepare-for-com-support
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET Uranium)
