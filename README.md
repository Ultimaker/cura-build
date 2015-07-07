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

## Ubuntu

See [ubuntu-15.04-build-script.sh](ubuntu-15.04-build-script.sh) for building under Ubuntu 15.04.
