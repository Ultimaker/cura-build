find_package(PythonInterp 3 REQUIRED)
if(NOT BUILD_OS_WINDOWS)
    # Only ask for Qt5 where it is actually built via cura-build-environment.
    # On Windows we are using PyQt5 to provide our libraries prebuilt.
    #find_package(Qt5 5.15.0 REQUIRED Core Qml Quick Widgets)
endif()
find_package(PyQt 5.15 REQUIRED)
find_package(SciPy 1.2.0 REQUIRED)

# WORKAROUND: CMAKE_ARGS itself is a string list with items separated by ';'. Passing a string list that's also
# separated by ';' as an argument via CMAKE_ARGS will make it confused. Converting it to "," and then to ";" is a
# workaround.
string(REPLACE ";" "," _cura_no_install_plugins "${CURA_NO_INSTALL_PLUGINS}")

ExternalProject_Add(Uranium
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG origin/${URANIUM_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DUM_NO_INSTALL_PLUGINS=${_cura_no_install_plugins}
)

SetProjectDependencies(TARGET Uranium)

add_dependencies(update Uranium-update)
