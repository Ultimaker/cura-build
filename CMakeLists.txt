project(cura-build)

cmake_minimum_required(VERSION 2.8.12)

include(ExternalProject)

if(APPLE)
   set(CMAKE_OSX_DEPLOYMENT_TARGET "10.7")
endif()

set(CURA_MAJOR_VERSION "15")
set(CURA_MINOR_VERSION "05")
set(CURA_PATCH_VERSION "92")

set(BRANCHNAME "15.06" CACHE STRING "The name of the branch to build")
set(EXTERNALPROJECT_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/inst)

ExternalProject_Add(Python 
    URL https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tgz
    CONFIGURE_COMMAND ./configure --prefix=${EXTERNALPROJECT_INSTALL_PREFIX} --enable-shared --with-threads --without-pymalloc
    BUILD_IN_SOURCE 1
)

set(PYTHON_BIN ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/python3)

ExternalProject_Add(Qt 
    URL http://download.qt.io/official_releases/qt/5.4/5.4.1/single/qt-everywhere-opensource-src-5.4.1.tar.gz
    CONFIGURE_COMMAND ./configure -release -prefix ${EXTERNALPROJECT_INSTALL_PREFIX} -archdatadir ${EXTERNALPROJECT_INSTALL_PREFIX}/lib -datadir ${EXTERNALPROJECT_INSTALL_PREFIX}/share -opensource -confirm-license -no-framework -nomake examples -nomake tests -skip qtconnectivity -skip qtdoc -skip qtenginio -skip qtlocation -skip qtmultimedia -skip qtquick1 -skip qtscript -skip qtscript -skip qtsensors -skip qtwebchannel -skip qtwebengine -skip qtwebkit -skip qtwebsockets -skip qtx11extras -skip qtandroidextras -skip qtactiveqt -skip qttools -skip qtwinextras -skip qtxmlpatterns
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(Sip
    DEPENDS Python
    URL http://downloads.sourceforge.net/project/pyqt/sip/sip-4.16.7/sip-4.16.7.tar.gz
    CONFIGURE_COMMAND ${PYTHON_BIN} configure.py --sysroot ${EXTERNALPROJECT_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(PyQt 
    DEPENDS Python Qt Sip
    URL http://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.4.1/PyQt-gpl-5.4.1.tar.gz
    CONFIGURE_COMMAND ${PYTHON_BIN} configure.py --sysroot ${EXTERNALPROJECT_INSTALL_PREFIX} --qmake ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/qmake --sip ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/sip --confirm-license
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(Protobuf 
    GIT_REPOSITORY https://github.com/ultimaker/protobuf
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
)

ExternalProject_Add(Protobuf-python
    DEPENDS Python Protobuf
    GIT_REPOSITORY https://github.com/ultimaker/protobuf
    CONFIGURE_COMMAND ""
    BUILD_COMMAND cd python && PROTOC=${EXTERNALPROJECT_INSTALL_PREFIX}/bin/protoc ${PYTHON_BIN} setup.py build
    INSTALL_COMMAND cd python && ${PYTHON_BIN} setup.py install
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(Arcus 
    DEPENDS Python Protobuf
    GIT_REPOSITORY https://github.com/ultimaker/libArcus
    GIT_TAG ${BRANCHNAME}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_STATIC=ON
)

ExternalProject_Add(CuraEngine
    DEPENDS Arcus
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG ${BRANCHNAME}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_BUILD_TYPE=Release
)

ExternalProject_Add(Numpy
    DEPENDS Python
    URL http://downloads.sourceforge.net/project/numpy/NumPy/1.9.2/numpy-1.9.2.tar.gz
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${PYTHON_BIN} setup.py build
    INSTALL_COMMAND ${PYTHON_BIN} setup.py install
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(PySerial
    DEPENDS Python
    URL https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${PYTHON_BIN} setup.py build
    INSTALL_COMMAND ${PYTHON_BIN} setup.py install
    BUILD_IN_SOURCE 1
)

ExternalProject_Add(Uranium
    DEPENDS PyQt Arcus
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG ${BRANCHNAME}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

ExternalProject_Add(Cura 
    DEPENDS Uranium CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/Cura
    GIT_TAG ${BRANCHNAME}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DURANIUM_SCRIPTS_DIR=
)

ExternalProject_Add(Py2App
    DEPENDS Python
    URL https://pypi.python.org/packages/source/p/py2app/py2app-0.9.tar.gz
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${PYTHON_BIN} setup.py build
    INSTALL_COMMAND ${PYTHON_BIN} setup.py install
    BUILD_IN_SOURCE 1
)

if(APPLE)
    configure_file(setup_osx.py.in setup_osx.py @ONLY)

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/dist/Cura.app 
        COMMAND ${PYTHON_BIN}
        ARGS setup_osx.py py2app
        COMMENT "Running py2app"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    add_custom_target(build_app ALL DEPENDS ${CMAKE_BINARY_DIR}/dist/Cura.app)
    install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)

    set(CPACK_GENERATOR "DragNDrop")
endif()

set(CPACK_PACKAGE_NAME "Cura")
set(CPACK_PACKAGE_VENDOR "Ultimaker")
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_MINOR_VERSION})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_PATCH_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Cura 3D Printing Software")
set(CPACK_MONOLITHIC_INSTALL 1)

include(CPack)
