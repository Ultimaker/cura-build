
ExternalProject_Add(Cura-Doodle3D
    GIT_REPOSITORY https://github.com/Doodle3D/Doodle3D-cura-plugin
    GIT_TAG origin/master
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET Cura-Doodle3D DEPENDS Cura)
