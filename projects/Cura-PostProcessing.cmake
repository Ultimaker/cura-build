
ExternalProject_Add(Cura-PostProcessing
    GIT_REPOSITORY https://github.com/nallath/PostProcessingPlugin
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

SetProjectDependencies(TARGET Cura-PostProcessing DEPENDS Cura)
