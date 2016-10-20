
ExternalProject_Add(Cura-UM3NetworkPrinting
    GIT_REPOSITORY https://github.com/Ultimaker/UM3NetworkPrintingPlugin
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET Cura-UM3NetworkPrinting DEPENDS Cura)
