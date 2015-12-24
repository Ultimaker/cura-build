# cura-build

This repository contains build scripts used to build Cura and all depenencies from scratch.

## OS X

1. Install CMake (available via [homebrew](http://brew.sh/) or [cmake.org](http://www.cmake.org/))
2. Install latest version of Xcode.
3. Run these commands:
```shell
git clone git@github.com:Ultimaker/cura-build.git
cd cura-build
mkdir build
cd build
cmake ..
make
```

## Windows

On Windows, the following dependencies are needed for building:

* CMake (http://www.cmake.org/)
* MinGW-W64 >= 4.9.04 (http://mingw-w64.org/doku.php)
* Python 3.4 (http://python.org/, note that using Python 3.5 is currently untested on Windows)
* Microsoft DirectX SDK (http://www.microsoft.com/en-us/download/details.aspx?id=6812)
* Microsoft C++ Redistributable 2015 (microsoft.com/en-us/download/details.aspx?id=48145)

Additonally, for 32-bit builds:

* Perl (http://www.activestate.com/activeperl, Required to build Qt)

For 64-bit builds:

* PyQt 5.4 (https://riverbankcomputing.com/software/pyqt/download5, Building PyQt currently fails using MinGW 64-bit)
* Numpy from http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy (Building numpy also fails with MinGW 64-bit)

For creating installer we use NSIS 3: http://nsis.sourceforge.net/Main_Page

Make sure these dependencies are available from your path.

```shell
REM 32-bit
git clone git@github.com:Ultimaker/cura-build.git
cd cura-build
mkdir build
cd build
copy <src>/vc_redist.x32.exe .
..\env_win32.bat
cmake -G "MinGW Makefiles" ..
mingw32-make
mingw32-make package
```

```shell
REM 64-bit
git clone git@github.com:Ultimaker/cura-build.git
cd cura-build
mkdir build
cd build
copy <src>/vc_redist.x64.exe .
..\env_win64.bat
cmake -G "MinGW Makefiles" ..
mingw32-make
mingw32-make package
```

## Ubuntu/Linux

cura-build can build Ubuntu/Debian packages of Cura.

Dependencies:

* python3 (>= 3.4.0)
* python3-pyqt5 (>= 5.4.0)
* python3-pyqt5.qtopengl (>= 5.4.0)
* python3-pyqt5.qtquick (>= 5.4.0)
* python3-pyqt5.qtsvg (>= 5.4.0)
* python3-numpy (>= 1.8.0)
* python3-serial (>= 2.6)
* python3-opengl (>= 3.0)
* qml-module-qtquick2 (>= 5.4.0)
* qml-module-qtquick-window2 (>= 5.4.0)
* qml-module-qtquick-layouts (>= 5.4.0)
* qml-module-qtquick-dialogs (>= 5.4.0)
* qml-module-qtquick-controls (>= 5.4.0)

To build, make sure these dependencies are installed, then clone this repository and run the following commands from your clone:

```shell
mkdir build
cd build
cmake ..
make
make package
```
