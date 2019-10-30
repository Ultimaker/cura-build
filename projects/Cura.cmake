option(CURA_ENABLE_DEBUGMODE "Enable crash handler and other debug options in Cura" OFF)

# WORKAROUND: CMAKE_ARGS itself is a string list with items separated by ';'. Passing a string list that's also
# separated by ';' as an argument via CMAKE_ARGS will make it confused. Converting it to "," and then to ";" is a
# workaround.
string(REPLACE ";" "," _cura_no_install_plugins "${CURA_NO_INSTALL_PLUGINS}")

ExternalProject_Add(Cura
    GIT_REPOSITORY https://github.com/ultimaker/Cura
    GIT_TAG origin/${CURA_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DURANIUM_SCRIPTS_DIR=
               -DCURA_VERSION=${CURA_VERSION}
               -DCURA_BUILDTYPE=${CURA_BUILDTYPE}
               -DCURA_DEBUGMODE=${CURA_ENABLE_DEBUGMODE}
               -DCURA_CLOUD_API_ROOT=${CURA_CLOUD_API_ROOT}
               -DCURA_CLOUD_API_VERSION=${CURA_CLOUD_API_VERSION}
               -DCURA_CLOUD_ACCOUNT_API_ROOT=${CURA_CLOUD_ACCOUNT_API_ROOT}
               -DCURA_NO_INSTALL_PLUGINS=${_cura_no_install_plugins}
)

SetProjectDependencies(TARGET Cura DEPENDS Uranium CuraEngine)
