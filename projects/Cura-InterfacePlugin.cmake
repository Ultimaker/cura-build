
ExternalProject_Add(Cura-OctoPrint
    GIT_REPOSITORY https://github.com/thopiekar/CuraInterfacePlugin
    GIT_TAG origin/master
    CMAKE_GENERATOR "NMake Makefiles"
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
    BUILD_COMMAND nmake
    INSTALL_COMMAND nmake install
)

SetProjectDependencies(TARGET Cura-OctoPrint DEPENDS Cura)
