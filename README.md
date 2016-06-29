# cura-build

This repository contains build scripts used to build Cura and all dependencies from scratch.

## OS X

1. Install CMake (available via [homebrew](http://brew.sh/) or [cmake.org](http://www.cmake.org/))
2. Install latest version of Xcode.
3. On Mac OS X > 10.10, execute command: *brew link openssl --force*
4. Because Fortran is necessary: *brew install gcc*
5. Run these commands:
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

* **git for windows** (https://git-for-windows.github.io/) The `git` command should be available on your `%PATH%`. Make sure that the `cmd` directory in the git for windows installation directory is on the `%PATH%` and *not* its `bin` directory, otherwise mingw32 will complain about `sh.exe` being on the path.
* **CMake** (http://www.cmake.org/) Once CMake is installed make sure it is available on your `%PATH%`. Check this by running `cmake --version` in the Windows console.
* **MinGW-W64** >= 4.9.04 (http://mingw-w64.org/doku.php) Once installed, its `bin` directory should be available on your `%PATH%`. Test this by running `mingw32-make --version` in the Windows console.
* **Python** 3.4 (http://python.org/, note that using Python 3.5 is currently untested on Windows)
* **NumPy** from http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy - make sure to get the NON-MKL version!
* **SciPy** from http://www.lfd.uci.edu/~gohlke/pythonlibs/#scipy
* **Microsoft Visual Studio 2015 (community edition)**: 
  Install Programming languages: Visual c++ (all), Python Tools for Visual Studio (Nov 2015)
  Windows & Web Development: Universal Windows App Development Tools (Tools 1.2 & windows 10 SDK-10/0/10586; Windows 10 SDK -10.0.10240)
* **Py2Exe** (https://pypi.python.org/pypi/py2exe/0.9.2.0/#downloads) The easiest way to install this is to run the command `pip install py2exe`. The executable `build_exe.exe` should now be in your `<python dir>/Scripts` directory. You may have to add `<python dir>/Scripts` to you `%PATH%`.
* **NSIS 3** (http://nsis.sourceforge.net/Main_Page) for creating the installer 

Make sure these dependencies are available from your path.

Additionally, for 32-bit builds:

* Perl (http://www.activestate.com/activeperl, Required to build Qt)
* Create in the user directory a file named pydistutils.cfg with the following contents:
```shell
[build]
compiler=mingw32
```

For 64-bit builds:

* PyQt 5.4 (https://riverbankcomputing.com/software/pyqt/download5, Building PyQt currently fails using MinGW 64-bit)
* Install protobuf.wheel found in cura-build-binaries (TODO: create cura-build-binaries repo)
* Create empty __init__.py in c:\Python34\Lib\site-packages\google (TODO: make it part of the proto.wheel installation)

```shell
REM 32-bit
git clone git@github.com:Ultimaker/cura-build.git
cd cura-build
mkdir build
cd build
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
..\env_win64.bat
cmake -G "MinGW Makefiles" -DBUILD_64BIT:BOOL=ON ..
mingw32-make
mingw32-make package
```

Before make package - copy arduino to cura-build/

## Ubuntu/Linux

cura-build can build Ubuntu/Debian packages of Cura.

Dependencies:

* python3 (>= 3.4.0)
* python3-dev (>= 3.4.0)
* python3-pyqt5 (>= 5.4.0)
* python3-pyqt5.qtopengl (>= 5.4.0)
* python3-pyqt5.qtquick (>= 5.4.0)
* python3-pyqt5.qtsvg (>= 5.4.0)
* python3-numpy (>= 1.8.0)
* python3-serial (>= 2.6)
* python3-opengl (>= 3.0)
* python3-setuptools
* python3-dev
* qml-module-qtquick2 (>= 5.4.0)
* qml-module-qtquick-window2 (>= 5.4.0)
* qml-module-qtquick-layouts (>= 5.4.0)
* qml-module-qtquick-dialogs (>= 5.4.0)
* qml-module-qtquick-controls (>= 5.4.0)
* zlib1g
* build-essential
* cmake
* gfortran

To build, make sure these dependencies are installed, then clone this repository and run the following commands from your clone:

```shell
sudo apt-get install gfortran python3 python3-dev python3-pyqt5 python3-pyqt5.qtopengl python3-pyqt5.qtquick python3-pyqt5.qtsvg python3-numpy python3-serial python3-opengl python3-setuptools qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtquick-layouts qml-module-qtquick-dialogs qml-module-qtquick-controls gfortran
git clone http://github.com/Ultimaker/cura-build.git
cd cura-build
```

```shell
mkdir build
cd build
cmake ..
make
make package
```
