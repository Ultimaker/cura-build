project(cura-build)

cmake_minimum_required(VERSION 2.8.12)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(ExternalProject)
include(GNUInstallDirs)

# Define Options
option(BUILD_PYTHON "Include Python" ON)
option(BUILD_QT "Include Qt" ON)
option(BUILD_SIP "Include SIP" ON)
option(BUILD_PYQT "Include PyQt" ON)
option(BUILD_NUMPY "Include Numpy" ON)
option(BUILD_SCIPY "Include Scipy" ON)
option(BUILD_PYSERIAL "Include PySerial" ON)
option(BUILD_NUMPY_STL "Include Numpy-STL" ON)
option(BUILD_ZEROCONF "Include python-zeroconf" ON)

if(WIN32)
    option(BUILD_64BIT "Create a 64-bit build" OFF)
endif()

# Create variables to simplify OS management
set(BUILD_OS_OSX OFF)
set(BUILD_OS_LINUX OFF)
set(BUILD_OS_WINDOWS OFF)
set(BUILD_OS_WIN32 OFF)
set(BUILD_OS_WIN64 OFF)

if(CYGWIN)
    message(FATAL_ERROR "Cygwin is not supported")
endif()

if(APPLE)
    set(BUILD_OS_OSX ON)
elseif(WIN32)
    set(BUILD_OS_WINDOWS ON)
    if(BUILD_64BIT)
        set(BUILD_OS_WIN64 ON)
    else()
        set(BUILD_OS_WIN32 ON)
    endif()
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(BUILD_OS_LINUX ON)
else()
    message(FATAL_ERROR "Unsupported Operating System: ${CMAKE_SYSTEM_NAME}")
endif()

# Explicitly disable unsupported options
if(BUILD_OS_WINDOWS)
    set(BUILD_PYTHON OFF)

    # Disable building of Numpy and Scipy due to build failures.
    set(BUILD_NUMPY OFF)
    set(BUILD_SCIPY OFF)
    set(BUILD_NUMPY_STL OFF)
    set(BUILD_ZEROCONF OFF)

    # On Win32, MinGW built Qt ignores environment variable changes made when running the
    # application. Since we need that to disable the threaded renderer, we need to use an
    # MSVC built Qt/PyQt for now.
    #
    # On Win64, in addition MinGW built python extensions fail to load properly so we cannot
    # use it at all.
    set(BUILD_QT OFF)
    set(BUILD_PYQT OFF)
    if(BUILD_OS_WIN64)
        # Sip is required to build the Arcus python bindings, which works fine on Win32
        # but fails on Win64. So we need an externally built SIP and Arcus bindings on Win64.
        set(BUILD_SIP OFF)
    endif()
elseif(BUILD_OS_LINUX)
    set(BUILD_PYTHON OFF)
endif()

set(TAG_OR_BRANCH "master" CACHE STRING "The name of the tag or branch to build")
set(EXTRA_REPOSITORIES "" CACHE STRING "Extra repositories to install. Expected to have a CMake based build system.")
set(EXTERNALPROJECT_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/inst)
set(EXTERNALPROJECT_SITEPACKAGES_DIR ${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.4/site-packages)

# Create the version-related variables
# These can optionally be overridden from the build enviroment.
if(DEFINED ENV{CURA_MAJOR_VERSION})
    set(CURA_MAJOR_VERSION $ENV{CURA_MAJOR_VERSION} CACHE STRING "Cura Major Version" FORCE)
else()
    set(CURA_MAJOR_VERSION "master" CACHE STRING "Cura Major Version")
endif()

if(DEFINED ENV{CURA_MINOR_VERSION})
    set(CURA_MINOR_VERSION $ENV{CURA_MINOR_VERSION} CACHE STRING "Cura Minor Version" FORCE)
else()
    set(CURA_MINOR_VERSION "0" CACHE STRING "Cura Minor Version")
endif()

if(DEFINED ENV{CURA_PATCH_VERSION})
    set(CURA_PATCH_VERSION $ENV{CURA_PATCH_VERSION} CACHE STRING "Cura Patch Version" FORCE)
else()
    set(CURA_PATCH_VERSION "0" CACHE STRING "Cura Patch Version")
endif()

if(DEFINED ENV{CURA_EXTRA_VERSION})
    set(CURA_EXTRA_VERSION $ENV{CURA_EXTRA_VERSION} CACHE STRING "Cura Extra Version Information" FORCE)
else()
    set(CURA_EXTRA_VERSION "${TAG_OR_BRANCH}" CACHE STRING "Cura Extra Version Information")
endif()

set(CURA_VERSION "${CURA_MAJOR_VERSION}.${CURA_MINOR_VERSION}.${CURA_PATCH_VERSION}")
if(NOT "${CURA_EXTRA_VERSION}" STREQUAL "")
    set(CURA_VERSION "${CURA_VERSION}-${CURA_EXTRA_VERSION}")
endif()

message(STATUS "Building Cura ${CURA_VERSION}")

if(BUILD_OS_WIN32)
    # To deal with stupid setuptools not creating install directories
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/inst/lib/python3.4/site-packages)
endif()

if(BUILD_PYTHON)
    if(APPLE)
        # See http://bugs.python.org/issue21381
        # The interpreter crashes when MACOSX_DEPLOYMENT_TARGET=10.7 due to the increased stack size.
        set(patch_command sed -i".bak" "8704,8704d" <SOURCE_DIR>/configure)
    endif()

    ExternalProject_Add(Python
        URL https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tgz
        PATCH_COMMAND ${patch_command}
        CONFIGURE_COMMAND ./configure --prefix=${EXTERNALPROJECT_INSTALL_PREFIX} --enable-shared --with-threads --without-pymalloc
        BUILD_IN_SOURCE 1
    )

    set(PYTHON_EXECUTABLE ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/python3)
    set(PYTHON_VERSION_MAJOR 3)
    set(PYTHON_VERSION_MINOR 4)
else()
    find_package(PythonInterp 3.4.0 REQUIRED)
    add_custom_target(Python)
endif()

if(BUILD_QT)
    set(qt_url http://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.tar.gz)
    set(qt_md5 59f0216819152b77536cf660b015d784)

    # Qt uses different sources for Windows 
    if(BUILD_OS_WINDOWS)
        set(qt_url http://download.qt.io/official_releases/qt/5.5/5.5.1/single/qt-everywhere-opensource-src-5.5.1.zip)
        set(qt_md5 d071cdaa1b8f34fb49f6deac94039c2c)
    endif()

    set(qt_options
        -release
        -prefix ${EXTERNALPROJECT_INSTALL_PREFIX}
        -archdatadir ${EXTERNALPROJECT_INSTALL_PREFIX}/lib
        -datadir ${EXTERNALPROJECT_INSTALL_PREFIX}/share
        -opensource
        -confirm-license
        -nomake examples
        -nomake tests
        -nomake tools
        -no-cups
        -no-sql-db2
        -no-sql-ibase
        -no-sql-mysql
        -no-sql-oci
        -no-sql-odbc
        -no-sql-psql
        -no-sql-sqlite
        -no-sql-sqlite2
        -no-sql-tds
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
        -skip qtandroidextras
        -skip qtactiveqt
        -skip qttools
        -skip qtxmlpatterns
        -skip qt3d
        -skip qtcanvas3d
        -skip qtserialport
        -skip qtwayland
        -skip qtwebkit-examples
    )

    if(BUILD_OS_OSX)
        list(APPEND qt_options -no-framework)
    elseif(BUILD_OS_WINDOWS)
        list(APPEND qt_options -opengl desktop)
    elseif(BUILD_OS_LINUX)
        list(APPEND qt_options -no-rpath -qt-xcb)
    endif()

    ExternalProject_Add(Qt
        URL ${qt_url}
        URL_MD5 ${qt_md5}
        CONFIGURE_COMMAND ./configure ${qt_options}
        BUILD_IN_SOURCE 1
    )
else()
    add_custom_target(Qt)
endif()

if(BUILD_SIP)
    set(sip_command "")
    if(BUILD_OS_WINDOWS)
        set(sip_command
            ${PYTHON_EXECUTABLE}
            configure.py
            --platform win32-g++
            --bindir=${EXTERNALPROJECT_INSTALL_PREFIX}/bin
            --destdir=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.4/site-packages
            --incdir=${EXTERNALPROJECT_INSTALL_PREFIX}/include
            --sipdir=${EXTERNALPROJECT_INSTALL_PREFIX}/share/sip
            "CFLAGS+=${CMAKE_C_FLAGS}"
            "CXXFLAGS+=${CMAKE_CXX_FLAGS}"
        )
    elseif(BUILD_OS_LINUX)
        set(sip_command
            ${PYTHON_EXECUTABLE}
            configure.py
            --bindir=${EXTERNALPROJECT_INSTALL_PREFIX}/bin
            --destdir=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages
            --incdir=${EXTERNALPROJECT_INSTALL_PREFIX}/include
            --sipdir=${EXTERNALPROJECT_INSTALL_PREFIX}/share/sip
        )
    elseif(BUILD_OS_OSX)
        set(sip_command ${PYTHON_EXECUTABLE} configure.py --sysroot=${EXTERNALPROJECT_INSTALL_PREFIX})
    endif()

    ExternalProject_Add(Sip
        DEPENDS Python
        URL http://downloads.sourceforge.net/project/pyqt/sip/sip-4.17/sip-4.17.zip
        CONFIGURE_COMMAND ${sip_command}
        BUILD_IN_SOURCE 1
    )
else()
    add_custom_target(Sip)
endif()

if(BUILD_PYQT)
    set(pyqt_command "")
    if(BUILD_OS_WINDOWS)
        set(pyqt_command
            ${PYTHON_EXECUTABLE} configure.py
            --sip ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/sip.exe
            --confirm-license
            --spec win32-g++
            --destdir ${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.4/site-packages
            --bindir ${EXTERNALPROJECT_INSTALL_PREFIX}/bin
            --sipdir ${EXTERNALPROJECT_INSTALL_PREFIX}/share/sip
            "CFLAGS+=${CMAKE_C_FLAGS}"
            "CXXFLAGS+=${CMAKE_CXX_FLAGS}"
        )
    elseif(BUILD_OS_LINUX)
        set(pyqt_command
            ${PYTHON_EXECUTABLE} configure.py
            --sip ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/sip
            --qmake ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/qmake
            --confirm-license
            --destdir ${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages
            --bindir ${EXTERNALPROJECT_INSTALL_PREFIX}/bin
            --sipdir ${EXTERNALPROJECT_INSTALL_PREFIX}/share/sip
        )
    elseif(BUILD_OS_OSX)
        set(pyqt_command
            ${PYTHON_EXECUTABLE} configure.py
            --sysroot ${EXTERNALPROJECT_INSTALL_PREFIX}
            --qmake ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/qmake
            --sip ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/sip
            --confirm-license
        )
    endif()

    # This patches the PyQt 5.4.2 source code to remove the "disconnectNotify" method from QPyQmlObject.
    # This fixes a deadlock that could randomly occur when deleting QML items.
    # This workaround should be removed as soon as a new stable release of PyQt is available that includes the fix.
    set(pyqt_patch
        patch qpy/QtQml/qpyqmlobject.cpp ${CMAKE_SOURCE_DIR}/qpyqmlobject.cpp.patch && patch qpy/QtQml/qpyqmlobject.h ${CMAKE_SOURCE_DIR}/qpyqmlobject.h.patch
    )

    ExternalProject_Add(PyQt
        DEPENDS Python Qt Sip
        URL http://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-5.4.2/PyQt-gpl-5.4.2.tar.gz
        PATCH_COMMAND ${pyqt_patch}
        CONFIGURE_COMMAND ${pyqt_command}
        BUILD_IN_SOURCE 1
    )
else()
    add_custom_target(PyQt)
endif()

if(BUILD_OS_WINDOWS)
    # Because setuptools is stupid and will interpret "C:/..." as a relative path
    string(REPLACE "/" "\\" native_prefix ${EXTERNALPROJECT_INSTALL_PREFIX})
    set(python_install
        --install-lib=${native_prefix}\\lib\\python3.4\\site-packages 
        --install-data=${native_prefix}\\share
        --install-scripts=${native_prefix}\\bin
    )
elseif(BUILD_OS_LINUX)
    set(python_install
        --root=${EXTERNALPROJECT_INSTALL_PREFIX}
        --install-lib=lib/python3/dist-packages
    )
endif()

if((BUILD_NUMPY OR BUILD_SCIPY) AND BUILD_OS_LINUX)
    # Fortran compiler is needed for OpenBLAS, but it does no check whether it is available.
    enable_language (Fortran)
    set(openblas_options DYNAMIC_ARCH=1 NO_STATIC=1)
    ExternalProject_Add(OpenBLAS
        URL https://github.com/xianyi/OpenBLAS/archive/v0.2.15.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND make ${openblas_options}
        INSTALL_COMMAND make PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} ${openblas_options} install
        BUILD_IN_SOURCE 1
    )
else()
    add_custom_target(OpenBLAS)
endif()

if(BUILD_NUMPY)
    if(BUILD_OS_LINUX)
        # Inform numpy about using OpenBLAS
        set(build_numpy "OPENBLAS=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/libopenblas.so" ${PYTHON_EXECUTABLE} setup.py build)
        set(install_numpy "OPENBLAS=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/libopenblas.so" ${PYTHON_EXECUTABLE} setup.py install ${python_install})
    else()
        set(build_numpy ${PYTHON_EXECUTABLE} setup.py build)
        set(install_numpy ${PYTHON_EXECUTABLE} setup.py install ${python_install})
    endif()

    ExternalProject_Add(Numpy
        DEPENDS Python OpenBLAS
        URL http://downloads.sourceforge.net/project/numpy/NumPy/1.9.2/numpy-1.9.2.tar.gz
        URL_MD5 a1ed53432dbcd256398898d35bc8e645
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${build_numpy}
        INSTALL_COMMAND ${install_numpy}
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_SCIPY)
    if(BUILD_OS_LINUX)
        # Inform scipy about using OpenBLAS
        set(build_scipy "OPENBLAS=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/libopenblas.so" "PYTHONPATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages/" "LD_LIBRARY_PATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib" ${PYTHON_EXECUTABLE} setup.py build)
        set(install_scipy "OPENBLAS=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/libopenblas.so" "PYTHONPATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages/" "LD_LIBRARY_PATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib" ${PYTHON_EXECUTABLE} setup.py install ${python_install})
    else()
        set(build_scipy ${PYTHON_EXECUTABLE} setup.py build)
        set(install_scipy  ${PYTHON_EXECUTABLE} setup.py install ${python_install})
    endif()

    ExternalProject_Add(Scipy
        DEPENDS Python Numpy
        URL http://downloads.sourceforge.net/project/scipy/scipy/0.16.1/scipy-0.16.1.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${build_scipy}
        INSTALL_COMMAND ${install_scipy}
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_PYSERIAL)
    ExternalProject_Add(PySerial
        DEPENDS Python
        URL https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz
        URL_MD5 794506184df83ef2290de0d18803dd11
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install ${python_install}
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_NUMPY_STL)
    ExternalProject_Add(NumpySTL
        DEPENDS Python
        URL https://github.com/WoLpH/numpy-stl/archive/v1.9.0.tar.gz
        URL_MD5 cda2531edecff4468a4bbe78c6a2833b
        CONFIGURE_COMMAND ""
        BUILD_COMMAND "PYTHONPATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages/" ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND "PYTHONPATH=${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3/dist-packages/" ${PYTHON_EXECUTABLE} setup.py install ${python_install}
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_ZEROCONF)
    ExternalProject_Add(PythonNetifaces
        DEPENDS Python
        URL https://pypi.python.org/packages/18/fa/dd13d4910aea339c0bb87d2b3838d8fd923c11869b1f6e741dbd0ff3bc00/netifaces-0.10.4.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install ${python_install}
        BUILD_IN_SOURCE 1
    )

    ExternalProject_Add(PythonZeroconf
        DEPENDS PythonNetifaces
        URL https://github.com/jstasiak/python-zeroconf/archive/0.17.5.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install ${python_install}
        BUILD_IN_SOURCE 1
    )
endif()

if(BUILD_OS_OSX)
    set(protobuf_cxx_flags "-fPIC -std=c++11 -stdlib=libc++")
else()
    set(protobuf_cxx_flags "-fPIC -std=c++11")
endif()

ExternalProject_Add(Protobuf
    URL https://github.com/google/protobuf/archive/v3.0.0-beta-2.tar.gz
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_INSTALL_LIBDIR=lib -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_CXX_FLAGS=${protobuf_cxx_flags} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -G ${CMAKE_GENERATOR} ../Protobuf/cmake
)

if(BUILD_OS_WIN64)
    # Due to problems building Python modules on Win64 we currently need to disable building Arcus.
    set(ARCUS_EXTRA_ARGS -DBUILD_PYTHON=OFF)
endif()

ExternalProject_Add(Arcus
    DEPENDS Python Protobuf Sip
    GIT_REPOSITORY https://github.com/ultimaker/libArcus
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DBUILD_EXAMPLES=OFF -DBUILD_STATIC=ON -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ${ARCUS_EXTRA_ARGS}
)

ExternalProject_Add(CuraEngine
    DEPENDS Arcus
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCURA_ENGINE_VERSION=${CURA_VERSION} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
)

ExternalProject_Add(Uranium
    DEPENDS PyQt Arcus
    GIT_REPOSITORY https://github.com/ultimaker/Uranium
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

ExternalProject_Add(Cura
    DEPENDS Uranium CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/Cura
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DURANIUM_SCRIPTS_DIR= -DCURA_VERSION=${CURA_VERSION}
)

ExternalProject_Add(Cura-PostProcessing
    DEPENDS Cura
    GIT_REPOSITORY https://github.com/nallath/PostProcessingPlugin
    GIT_TAG origin/master
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

ExternalProject_Add(cura-binary-data
    DEPENDS Cura
    GIT_REPOSITORY https://github.com/ultimaker/cura-binary-data
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

ExternalProject_Add(Cura-Doodle3D
    DEPENDS Cura
    GIT_REPOSITORY https://github.com/Doodle3D/Doodle3D-cura-plugin
    GIT_TAG origin/master
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX}
)

foreach(repo ${EXTRA_REPOSITORIES})
    separate_arguments(items UNIX_COMMAND "${repo}")
    list(GET items 0 name)
    list(GET items 1 repo)
    list(REMOVE_AT items 0 1)

    set(cmake "")
    foreach(item ${items})
        list(APPEND cmake ${item})
    endforeach()

    ExternalProject_Add(${name}
        GIT_REPOSITORY ${repo}
        GIT_TAG origin/master
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} ${cmake}
    )
endforeach()

if(BUILD_OS_OSX)
    ExternalProject_Add(Py2App
        DEPENDS Python
        URL https://pypi.python.org/packages/source/p/py2app/py2app-0.9.tar.gz
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install
        BUILD_IN_SOURCE 1
    )
elseif(BUILD_OS_WINDOWS)
    # Currently, py2exe can not be built with MinGW since the code apparently uses
    # a lot of MSVC-isms. So instead, install py2exe in your Python installation and
    # use that.
    # ExternalProject_Add(Py2Exe
        # DEPENDS Python
        # URL https://pypi.python.org/packages/source/p/py2exe/py2exe-0.9.2.0.zip
        # CONFIGURE_COMMAND ""
        # BUILD_COMMAND ${PYTHON_EXECUTABLE} setup.py build
        # INSTALL_COMMAND ${PYTHON_EXECUTABLE} setup.py install ${python_install}
        # BUILD_IN_SOURCE 1
    # )
endif()

if(BUILD_OS_OSX)
    configure_file(setup_osx.py.in setup_osx.py @ONLY)

    add_custom_target(build_app ALL)
    add_dependencies(build_app cura-binary-data)

    foreach(repo ${EXTRA_REPOSITORIES})
        separate_arguments(items UNIX_COMMAND "${repo}")
        list(GET items 0 name)
        add_dependencies(build_app ${name})
    endforeach()

    add_custom_command(
        TARGET build_app PRE_LINK
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/dist
        COMMENT "Cleaning old dist/ directory"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    add_custom_command(
        TARGET build_app POST_BUILD
        COMMAND ${PYTHON_EXECUTABLE} setup_osx.py py2app
        COMMENT "Running py2app"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)

    set(CPACK_GENERATOR "DragNDrop")
elseif(BUILD_OS_WINDOWS)
    get_filename_component(compiler_dir ${CMAKE_CXX_COMPILER} DIRECTORY)
    configure_file(setup_win32.py.in setup_win32.py @ONLY)

    add_custom_target(build_exe ALL)
    add_dependencies(build_exe cura-binary-data)

    foreach(repo ${EXTRA_REPOSITORIES})
        separate_arguments(items UNIX_COMMAND "${repo}")
        list(GET items 0 name)
        add_dependencies(build_exe ${name})
    endforeach()

    add_custom_command(
        TARGET build_exe PRE_LINK
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/dist
        COMMENT "Cleaning old dist/ directory"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    add_custom_command(
        TARGET build_exe POST_BUILD
        COMMAND ${PYTHON_EXECUTABLE} setup_win32.py py2exe
        COMMENT "Running py2exe"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/ DESTINATION "." USE_SOURCE_PERMISSIONS COMPONENT "cura")

    if(BUILD_OS_WIN32)
        install(FILES ${EXTERNALPROJECT_INSTALL_PREFIX}/vcredist_x32.exe DESTINATION "." COMPONENT "vcredist")
    else()
        install(FILES ${EXTERNALPROJECT_INSTALL_PREFIX}/vcredist_x64.exe DESTINATION "." COMPONENT "vcredist")
    endif()

    install(DIRECTORY ${EXTERNALPROJECT_INSTALL_PREFIX}/arduino DESTINATION "." COMPONENT "arduino")

    include(CPackComponent)
    cpack_add_component(cura DISPLAY_NAME "Cura Executable and Data Files" REQUIRED)
    cpack_add_component(vcredist DISPLAY_NAME "Install Visual Studio 2010 Redistributable")
    cpack_add_component(arduino DISPLAY_NAME "Install Arduino Drivers")

    set(CPACK_GENERATOR "NSIS")
elseif(BUILD_OS_LINUX)
    set(CPACK_GENERATOR "DEB")

    set(CPACK_INSTALL_CMAKE_PROJECTS "")

    set(CPACK_INSTALLED_DIRECTORIES
        "${CMAKE_BINARY_DIR}/inst/bin;/opt/cura/bin"
        "${CMAKE_BINARY_DIR}/inst/lib;/opt/cura/lib"
        "${CMAKE_BINARY_DIR}/inst/share;/opt/cura/share"
    )

    set(package_dir "_CPack_Packages/Linux/${CPACK_GENERATOR}/Cura-${CURA_VERSION}-Linux/")
    set(CPACK_INSTALL_COMMANDS
        "${CMAKE_COMMAND} -E make_directory ${package_dir}/usr/bin"
        "${CMAKE_COMMAND} -E make_directory ${package_dir}/usr/share/applications"
        "${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cura ${package_dir}/usr/bin/"
        "${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/cura.desktop ${package_dir}/usr/share/applications/"
        "${CMAKE_COMMAND} -E copy /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.20 ${package_dir}/opt/cura/lib/libstdc++.so.6"
    )
endif()

set(CPACK_PACKAGE_NAME "Cura")
set(CPACK_PACKAGE_VENDOR "Ultimaker")
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_MINOR_VERSION})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_PATCH_VERSION})
set(CPACK_PACKAGE_VERSION ${CURA_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Cura 3D Printing Software")
set(CPACK_PACKAGE_CONTACT "Arjen Hiemstra <a.hiemstra@ultimaker.com>")
if(NOT BUILD_OS_OSX)
    set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE)
endif()
set(CPACK_PACKAGE_EXECUTABLES Cura "Cura ${CURA_MAJOR_VERSION}.${CURA_MINOR_VERSION}.${CURA_PATCH_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Cura ${CURA_MAJOR_VERSION}.${CURA_MINOR_VERSION}")

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
    "libgfortran3"
)
string(REPLACE ";" "," DEB_DEPENDS "${DEB_DEPENDS}")
set(CPACK_DEBIAN_PACKAGE_DEPENDS ${DEB_DEPENDS})
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
# Set the right epoch so Debian knows this is a more recent version
set(CPACK_DEBIAN_PACKAGE_VERSION "2:${CPACK_PACKAGE_VERSION}")

set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
set(CPACK_NSIS_MUI_FINISHPAGE_RUN "Cura.exe")
set(CPACK_NSIS_MENU_LINKS
    "https://ultimaker.com/en/support/software" "Cura Online Documentation"
    "https://github.com/ultimaker/cura" "Cura Development Resources"
)
if(BUILD_OS_WIN32)
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "32")
else()
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "64")
endif()

include(CPack)
