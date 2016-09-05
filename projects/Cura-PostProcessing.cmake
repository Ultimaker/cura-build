
ExternalProject_Add(Cura-PostProcessing
    GIT_REPOSITORY https://github.com/nallath/PostProcessingPlugin
    GIT_TAG origin/${CURA_GIT_TAG}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET Cura-PostProcessing DEPENDS Cura)
