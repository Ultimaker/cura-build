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

* CMake
* MinGW-W64 >= 4.9.04
* Python 3.4 (Note that some stuff will end up in your python's site-packages dir)
* Perl
* DirectX SDK (http://www.microsoft.com/en-us/download/details.aspx?id=6812)

For 64-bit builds:

* PyQt 5.4 (Building PyQt currently fails using MinGW 64-bit)
* Numpy from http://www.lfd.uci.edu/~gohlke/pythonlibs/#numpy (Building numpy also fails with MinGW 64-bit)
* 

Make sure these dependencies are available from your path.

To build, clone the repository, then create a build directory. From that directory, run "env_win32.bat".
Then run CMake using the MinGW Generator. Finally, call "mingw32-make" to build everything and "mingw32-make package"
to build the installer.

## Ubuntu

See [ubuntu-15.04-build-script.sh](ubuntu-15.04-build-script.sh) for building under Ubuntu 15.04.
