find_package(PythonInterp 3.5.0 REQUIRED)
find_package(Qt5 5.6.0 REQUIRED Core Qml Quick Widgets)
find_package(PyQt 5.6 REQUIRED)
find_package(SciPy 0.17 REQUIRED)

ExternalProject_Add(Uranium
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET Uranium)
