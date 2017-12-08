# Requires only:
# $ call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64"

if(BUILD_OS_WINDOWS)
    ExternalProject_Add(InterfacePlugin
        GIT_REPOSITORY https://github.com/thopiekar/CuraInterfacePlugin
        GIT_TAG origin/master
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
    )

    SetProjectDependencies(TARGET InterfacePlugin DEPENDS Cura)
endif()