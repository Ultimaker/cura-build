GetFromEnvironmentOrCache(
        NAME
            CURA_BRANCH_OR_TAG
        DEFAULT
            master
        DESCRIPTION
            "The name of the tag or branch to build for Cura")

# Create the version-related variables
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_MAJOR
        DESCRIPTION
            "Cura Major Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_MINOR
        DEFAULT
            0
        DESCRIPTION
            "Cura Minor Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_PATCH
        DEFAULT
            0
        DESCRIPTION
            "Cura Patch Version")
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION_EXTRA
        DESCRIPTION
            "Cura Extra Version Information")
if(NOT ${CURA_VERSION_EXTRA} STREQUAL "")
    set(CURA_VERSION_EXTRA "-${CURA_VERSION_EXTRA}")
endif()
set(_default_cura_version "${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}.${CURA_VERSION_PATCH}${CURA_VERSION_EXTRA}")
if(${_default_cura_version} VERSION_GREATER 0.0.0)
    set(CURA_VERSION ${_default_cura_version})
endif()
GetFromEnvironmentOrCache(
        NAME
            CURA_VERSION
        DESCRIPTION
            "Cura Extra Version Information"
        REQUIRED)

GetFromEnvironmentOrCache(
        NAME
            CURA_ENABLE_DEBUGMODE
        DEFAULT
            OFF
        DESCRIPTION
            "Enable crash handler and other debug options in Cura"
        BOOL)
GetFromEnvironmentOrCache(
        NAME
            CURA_CLOUD_API_ROOT
        DESCRIPTION
            "The cloud API root")
GetFromEnvironmentOrCache(
        NAME
            CURA_CLOUD_ACCOUNT_API_ROOT
        DESCRIPTION
            "The cloud account API root")
GetFromEnvironmentOrCache(
        NAME
            CURA_DIGITAL_FACTORY_URL
        DESCRIPTION
            "The Digit factory url")
GetFromEnvironmentOrCache(
        NAME
            CURA_MARKETPLACE_ROOT
        DESCRIPTION
            "The marketplace root")
GetFromEnvironmentOrCache(
        NAME
            URANIUM_SCRIPTS_DIR
        DESCRIPTION
            "The Uranium script directory")
GetFromEnvironmentOrCache(
        NAME
            CURA_NO_INSTALL_PLUGINS
        DESCRIPTION
            "A list of plugins to exclude from installation, should be separated by ','.")
GetFromEnvironmentOrCache(
        NAME
            CURA_BUILDTYPE
        DESCRIPTION
            "Build type of Cura, eg. 'testing'")

ExternalProject_Add(Cura
    GIT_REPOSITORY https://github.com/ultimaker/Cura
    GIT_TAG origin/${CURA_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DURANIUM_SCRIPTS_DIR=${URANIUM_SCRIPTS_DIR}
               -DCURA_VERSION=${CURA_VERSION}
               -DCURA_BUILDTYPE=${CURA_BUILDTYPE}
               -DCURA_DEBUGMODE=${CURA_DEBUGMODE}
               -DCURA_CLOUD_API_ROOT=${CURA_CLOUD_API_ROOT}
               -DCURA_CLOUD_API_VERSION=${CURA_CLOUD_API_VERSION}
               -DCURA_CLOUD_ACCOUNT_API_ROOT=${CURA_CLOUD_ACCOUNT_API_ROOT}
               -DCURA_DIGITAL_FACTORY_URL=${CURA_DIGITAL_FACTORY_URL}
               -DCURA_MARKETPLACE_ROOT=${CURA_MARKETPLACE_ROOT}
               -DCURA_NO_INSTALL_PLUGINS=${CURA_NO_INSTALL_PLUGINS}
)

SetProjectDependencies(TARGET Cura DEPENDS Uranium CuraEngine)

add_dependencies(update Cura-update)
