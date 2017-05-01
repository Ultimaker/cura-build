
ExternalProject_Add(Cura-OctoPrint
    GIT_REPOSITORY https://github.com/fieldOfView/OctoPrintPlugin
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET Cura-OctoPrint DEPENDS Cura)
