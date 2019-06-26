# cura-build

This repository contains build scripts used to build Cura and all dependencies from scratch.

The build has a number of dependencies. Ideally, these dependencies should be installed by the [cura-build-environment](https://github.com/Ultimaker/cura-build-environment) repository. Even with cura-build-environment though, some things may still be missing from your system that we haven't thought of.

## (WIP) Build with docker (for Linux AppImage only)

To build Linux AppImage with docker, you first need to have a working cura-build-environment docker image. Please check
the `WIP_fix_docker` branch in [cura-build-environment repository](https://github.com/ultimaker/cura-build-environment).

Assume that you have a working cura-build-environment docker image tagged as `cura-build-env:centos7`. To build an
AppImage, run:

```
./scripts/build.sh
```

If the build is successful, the resulting AppImage will placed in the `appimages/` directory.

To configure your AppImage build, you can use the following environment variables:

 - `CURA_VERSION_MAJOR`: Major version number of Cura (default `4`)
 - `CURA_VERSION_MINOR`: Minor version number of Cura (default `1`)
 - `CURA_VERSION_PATCH`: Patch version number of Cura (default `99`)
 - `CURA_VERSION_EXTRA`: Extra version string of Cura, which will be appended after `x.y.z` with `-<extra>`
                         (default `docker`)
 - `CURA_BUILD_NAME`: FIXME: default to `docker`, probably no use.
 - `CURA_SDK_VERSION`:   SDK version of Cura in the form of semantic versioning (default `6.0.0`)
 - `CURA_CLOUD_API_ROOT`: Root URL of Cura Cloud API (default `https://api.ultimaker.com`)
 - `CURA_CLOUD_API_VERSION`: Cura Cloud API version to use (default `1`)
 - `CURA_CLOUD_ACCOUNT_API_ROOT`: Root URL of Cura Cloud Account API (default `https://account.ultimaker.com`)

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
* **MinGW-W64** >= 5.3.0 (http://mingw-w64.org/doku.php) Once installed, its `bin` directory should be available on your `%PATH%`. Test this by running `mingw32-make --version` in the Windows console.
* **Python** 3.5 (http://python.org/, note that the version "3.5" is hardcoded across this project)
* **NumPy** (http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy)
  You'll need to download a .whl from this site for Python 3.5 and install it via `pip install <your_whl_file>.whl`.
* **SciPy** (http://www.lfd.uci.edu/~gohlke/pythonlibs/#scipy)
  You'll need to download a .whl from this site for Python 3.5 and install it via `pip install <your_whl_file>.whl`.
* **PySerial** from https://pypi.python.org/pypi/pyserial/3.2.1
  It can be easily installed via `pip3 install pyserial`
* **PyQt5** from https://pypi.python.org/pypi/PyQt5/5.7
  It can be easily installed via `pip3 install PyQt5`
* **SIP** from https://pypi.python.org/pypi/SIP/4.18.1
  It can be easily installed via `pip3 install sip`
* **Trimesh** from https://pypi.python.org/pypi/trimesh/2.32.1
  It can be easily installed via `pip3 install trimesh`
* **Shapely** from https://pypi.python.org/pypi/Shapely/1.6.4.post2
  It can be easily installed via `pip3 install shapely[vectorized]`. If it doesn't work, you'll need to download a .whl from https://www.lfd.uci.edu/~gohlke/pythonlibs/#shapely for Python 3.5 and install it via `pip install <your_whl_file>.whl`.
* **Zeroconf** from https://pypi.python.org/pypi/zeroconf/0.17.6
  It can be easily installed via `pip3 install zeroconf`
* **NumPy-STL** from https://pypi.python.org/pypi/numpy-stl/2.0.0
  It can be easily installed via `pip3 install numpy-stl`
* **LibArcus** from https://github.com/Ultimaker/libArcus
* **Microsoft Visual Studio 2015 (community edition)**: 
  Install Programming languages: Visual c++ (all), Python Tools for Visual Studio (Nov 2015)
  Windows & Web Development: Universal Windows App Development Tools (Tools 1.2 & windows 10 SDK-10/0/10586; Windows 10 SDK -10.0.10240)
* **cx_Freeze** (https://pypi.python.org/pypi/cx_Freeze)
  The easiest way to install this is to use a wheel (*.whl file) and install it via `pip install <your_whl_file>.whl`. You may have to add `<python dir>/Scripts` to your `%PATH%`. (Last tested version was: cx_Freeze-5.0-cp35-cp35m-win_amd64.whl)
* **NSIS 3** (http://nsis.sourceforge.net/Main_Page) for creating the installer. Additional NSIS scripts are shipped with this project.

Make sure these dependencies are available from your path.

```shell
REM 64-bit
git clone git@github.com:Ultimaker/cura-build.git
cd cura-build
mkdir build
cd build
..\env_win64.bat
cmake -G "MinGW Makefiles" ..
mingw32-make
mingw32-make package
```

Before make package - copy arduino to cura-build/

## Ubuntu/Linux

cura-build can build AppImage packages of Cura. The following dependencies are required:

* `apt install git cmake gcc python3`
* `python3 -m pip install numpy scipy pyserial pyqt5 sip trimesh shapely zeroconf numpy-stl`
* **LibArcus** from https://github.com/Ultimaker/libArcus
* **cx_Freeze** (https://pypi.python.org/pypi/cx_Freeze)
  The easiest way to install this is to use a wheel (*.whl file) and install it via `pip install <your_whl_file>.whl`. You may have to add `<python dir>/Scripts` to your `PATH`.
* **AppImageKit** from https://github.com/AppImage/AppImageKit

To build, make sure these dependencies are installed, then clone this repository and run the following commands from your clone:

```shell
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

## CentOS/Linux

cura-build can build CentOS/RHEL packages of Cura.

Dependencies:

* gcc-gfortran 
* python34.x86_64 
* python34-devel.x86_64 
* python34-numpy.x86_64 
* pyserial.noarch 
* PyOpenGL.noarch 
* python34-setuptools.noarch 
* wxPython.x86_64 
* libstdc++-static.x86_64 
* libstdc++-devel.x86_64 
* openssl.x86_64 
* openblas-devel.x86_64 
* python34-numpy-f2py.x86_64

To build, make sure these dependencies are installed, then clone this repository and run the following commands from your clone:

```shell
sudo yum install gcc-gfortran python34.x86_64 python34-devel.x86_64 python34-numpy.x86_64 pyserial.noarch PyOpenGL.noarch python34-setuptools.noarch wxPython.x86_64 libstdc++-static.x86_64 libstdc++-devel.x86_64 openssl.x86_64 openblas-devel.x86_64 python34-numpy-f2py.x86_64
```
1. download and install scipy from https://github.com/scipy/scipy/releases be sure to use python 3.5, eg. using sudo python3 setup.py 2. install (version in repository is for python 2.7)
3. download and install CMake from https://cmake.org/download/ and configure CMake to use ssl
4. download and install Qt5 from https://www.qt.io/download/
5. download and install PyQt5 from https://www.riverbankcomputing.com/software/pyqt/download5
6. download and install sip from https://www.riverbankcomputing.com/software/sip/download make sure the verion is 4.18 or newer

Alternative method for installing python at: https://edwards.sdsu.edu/research/installing-python3-4-and-the-scipy-stack-on-centos/ .
Make sure, that the PYTHONPATH can find dist-packages. 

```shell
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
