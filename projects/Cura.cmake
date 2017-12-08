option(CURA_ENABLE_DEBUGMODE "Enable crash handler and other debug options in Cura" OFF)

ExternalProject_Add(Cura
    GIT_REPOSITORY https://github.com/thopiekar/Cura
    GIT_TAG origin/master-prepare-for-com-support
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DURANIUM_SCRIPTS_DIR= -DCURA_VERSION=${CURA_VERSION} -DCURA_DEBUGMODE=${CURA_ENABLE_DEBUGMODE}
)

SetProjectDependencies(TARGET Cura DEPENDS Uranium CuraEngine)
