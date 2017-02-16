
ExternalProject_Add(cura-binary-data
    GIT_REPOSITORY https://github.com/thopiekar/cura-binary-data
    GIT_TAG origin/master-CURA-2713-clean
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET cura-binary-data DEPENDS Cura)
