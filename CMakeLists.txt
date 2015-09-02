project(cura-build)

cmake_minimum_required(VERSION 2.8.12)

include(ExternalProject)
include(GNUInstallDirs)

if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.7")
endif()

option(BUILD_PYTHON "Include Python" ON)
option(BUILD_QT "Include Qt" ON)
option(BUILD_PYQT "Include PyQt" ON)
option(BUILD_NUMPY "Include Numpy" ON)
option(BUILD_PYSERIAL "Include PySerial" ON)

if(WIN32)
    set(BUILD_PYTHON OFF)
elseif(NOT APPLE)
    set(BUILD_PYTHON OFF)
    set(BUILD_QT OFF)
    set(BUILD_PYQT OFF)
    set(BUILD_NUMPY OFF)
    set(BUILD_PYSERIAL OFF)
endif()

set(CURA_MAJOR_VERSION "00")
set(CURA_MINOR_VERSION "00")
set(CURA_PATCH_VERSION "00")

set(TAG_OR_BRANCH "master" CACHE STRING "The name of the tag or branch to build")
set(EXTERNALPROJECT_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/inst)
set(EXTERNALPROJECT_SITEPACKAGES_DIR ${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.4/site-packages)

if(BUILD_PYTHON)
    ExternalProject_Add(Python
        URL https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tgz
        CONFIGURE_COMMAND ./configure --prefix=${EXTERNALPROJECT_INSTALL_PREFIX} --enable-shared --with-threads --without-pymalloc
        BUILD_IN_SOURCE 1
    )

    set(PYTHON_EXECUTABLE ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/python3)
else()
    find_package(PythonInterp 3.4.0 REQUIRED)
    add_custom_target(Python)
endif()

if(BUILD_QT)
    set(qt_options
        -release
        -prefix ${EXTERNALPROJECT_INSTALL_PREFIX}
        -archdatadir ${EXTERNALPROJECT_INSTALL_PREFIX}/lib
        -datadir ${EXTERNALPROJECT_INSTALL_PREFIX}/share
        -opensource
        -confirm-license
        -nomake examples
        -nomake tests
        -skip qtconnectivity
        -skip qtdoc
        -skip qtenginio
        -skip qtlocation
        -skip qtmultimedia
        -skip qtquick1
        -skip qtscript
        -skip qtsensors
        -skip qtwebchannel
        -skip qtwebengine
        -skip qtwebkit
        -skip qtwebsockets
        -skip qtx11extras
        -skip qtandroidextras
        -skip qtactiveqt
        -skip qttools
        -skip qtxmlpatterns
    )

    if(APPLE)
        list(APPEND qt_options -no-framework)
    elseif(WIN32)
        list(APPEND qt_options -opengl desktop)
    endif()

    ExternalProject_Add(Qt
        URL http://download.qt.io/official_releases/qt/5.4/5.4.2/single/qt-everywhere-opensource-src-5.4.2.zip
        URL_MD5 b6a099fff154fcb0a0127619623d412f
        CONFIGURE_COMMAND ./configure ${qt_options}
        BUILD_IN_SOURCE 1
    )
else()
    find_package(Qt5 5.4 REQUIRED COMPONENTS Core Gui Widgets Quick)
    add_custom_target(Qt)
endif()

if(BUILD_PYQT)
    set(sip_command "")
    if(WIN32)
        set(sip_command ${PYTHON_EXECUTABLE} configure.py --platform win32-g++)
    else()
        set(sip_command ${PYTHON_EXECUTABLE} configure.py --sysroot=${EXTERNALPROJECT_INSTALL_PREFIX})
    endif()

    ExternalProject_Add(Sip
        DEPENDS Python
        URL http://downloads.sourceforge.net/project/pyqt/sip/sip-4.16.9/sip-4.16.9.zip
        CONFIGURE_COMMAND ${sip_command}
        BUILD_IN_SOURCE 1
    )

    ExternalProject_Add(PyQt
        DEPENDS Python Qt Sip
        URL http://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.4.1/PyQt-gpl-5.4.1.tar.gz
        CONFIGURE_COMMAND ${PYTHON_EXECUTABLE} configure.py --sysroot ${EXTERNALPROJECT_INSTALL_PREFIX} --qmake ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/qmake --sip ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/sip --confirm-license
        BUILD_IN_SOURCE 1
    )
else()
    add_custom_target(PyQt)
endif()

if(BUILD_NUMPY)
    ExternalProject_Add(Numpy
        DEPENDS Python
        URL http://downloads.sourceforge.net/project/numpy/NumPy/1.9.2/numpy-1.9.2.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_PYSERIAL)
    ExternalProject_Add(PySerial
        DEPENDS Python
        URL https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install
        BUILD_IN_SOURCE 1
    )
endif()

ExternalProject_Add(Protobuf 
    GIT_REPOSITORY https://github.com/ultimaker/protobuf
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release -DINSTALL_PYTHON=OFF -DBUILD_STATIC=ON
)

ExternalProject_Add(Protobuf-python
    DEPENDS Python Protobuf
    GIT_REPOSITORY https://github.com/ultimaker/protobuf
    CONFIGURE_COMMAND ""
    BUILD_COMMAND cd python && PROTOC=${EXTERNALPROJECT_INSTALL_PREFIX}/bin/protoc ${PYTHON_EXECUTABLE} setup.py build
    INSTALL_COMMAND cd python && export PYTHONPATH=${EXTERNALPROJECT_SITEPACKAGES_DIR} && ${PYTHON_EXECUTABLE} setup.py install --single-version-externally-managed --prefix=${EXTERNALPROJECT_INSTALL_PREFIX} --record=${CMAKE_BINARY_DIR}/protobuf.log
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(Arcus 
    DEPENDS Python Protobuf
    GIT_REPOSITORY https://github.com/ultimaker/libArcus
    GIT_TAG ${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_STATIC=ON
)

ExternalProject_Add(CuraEngine
    DEPENDS Arcus
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG ${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
)

ExternalProject_Add(Uranium
    DEPENDS PyQt Arcus
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG ${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

ExternalProject_Add(Cura
    DEPENDS Uranium CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/Cura
    GIT_TAG ${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DURANIUM_SCRIPTS_DIR=
)

if(APPLE)
    ExternalProject_Add(Py2App
        DEPENDS Python
        URL https://pypi.python.org/packages/source/p/py2app/py2app-0.9.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install
        BUILD_IN_SOURCE 1
    )
elseif(WIN32)
    ExternalProject_Add(Py2Exe
        DEPENDS Python
        URL https://pypi.python.org/packages/source/p/py2exe/py2exe-0.9.2.0.zip
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install
        BUILD_IN_SOURCE 1
    )
endif()

if(APPLE)
    configure_file(setup_osx.py.in setup_osx.py @ONLY)

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/dist/Cura.app 
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS setup_osx.py py2app
        COMMENT "Running py2app"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    add_custom_target(build_app ALL DEPENDS ${CMAKE_BINARY_DIR}/dist/Cura.app)
    install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)

    set(CPACK_GENERATOR "DragNDrop")
elseif(WIN32)
    set(CPACK_GENERATOR "NSIS")

else()
    set(CPACK_GENERATOR "DEB")

    set(CPACK_INSTALL_CMAKE_PROJECTS
        "${CMAKE_BINARY_DIR}/Arcus-prefix/src/Arcus-build;Arcus;ALL;/usr"
        "${CMAKE_BINARY_DIR}/CuraEngine-prefix/src/CuraEngine-build;CuraEngine;ALL;/usr"
        "${CMAKE_BINARY_DIR}/Uranium-prefix/src/Uranium-build;Uranium;ALL;/usr"
        "${CMAKE_BINARY_DIR}/Cura-prefix/src/Cura-build;Cura;ALL;/usr"
    )
    set(CPACK_INSTALLED_DIRECTORIES "${CMAKE_BINARY_DIR}/inst/lib/python3.4/site-packages/google;/usr/lib/python3/dist-packages/google")
endif()

set(CPACK_PACKAGE_NAME "Cura")
set(CPACK_PACKAGE_VENDOR "Ultimaker")
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_MINOR_VERSION})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_PATCH_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Cura 3D Printing Software")
set(CPACK_PACKAGE_CONTACT "Arjen Hiemstra <a.hiemstra@ultimaker.com>")

set(RPM_REQUIRES
    "python3 >= 3.4.0"
    "python3-qt5 >= 5.4.0"
    "python3-numpy >= 1.9.0"
    "qt5-qtquickcontrols >= 5.4.0"
)
string(REPLACE ";" "," RPM_REQUIRES "${RPM_REQUIRES}")
set(CPACK_RPM_PACKAGE_REQUIRES ${RPM_REQUIRES})
set(CPACK_RPM_PACKAGE_RELOCATABLE OFF)

set(DEB_DEPENDS
    "python3 (>= 3.4.0)"
    "python3-pyqt5 (>= 5.4.0)"
    "python3-pyqt5.qtopengl (>= 5.4.0)"
    "python3-pyqt5.qtquick (>= 5.4.0)"
    "python3-pyqt5.qtsvg (>= 5.4.0)"
    "python3-numpy (>= 1.8.0)"
    "python3-serial (>= 2.6)"
    "qml-module-qtquick2 (>= 5.4.0)"
    "qml-module-qtquick-window2 (>= 5.4.0)"
    "qml-module-qtquick-layouts (>= 5.4.0)"
    "qml-module-qtquick-dialogs (>= 5.4.0)"
    "qml-module-qtquick-controls (>= 5.4.0)"
)
string(REPLACE ";" "," DEB_DEPENDS "${DEB_DEPENDS}")
set(CPACK_DEBIAN_PACKAGE_DEPENDS ${DEB_DEPENDS})
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)

include(CPack)
