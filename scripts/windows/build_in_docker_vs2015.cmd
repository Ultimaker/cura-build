rem This is the build script that should be executed in the Windows docker container
rem to build a Cura release.

@echo OFF

echo ========== Build Variables BEGIN ==========
echo CURA_BUILD_ENV_PATH    = "%CURA_BUILD_ENV_PATH%"
echo CURA_BUILD_SRC_PATH    = "%CURA_BUILD_SRC_PATH%"
echo CURA_BUILD_OUTPUT_PATH = "%CURA_BUILD_OUTPUT_PATH%"
echo
echo CURA_BRANCH_OR_TAG           = "%CURA_BRANCH_OR_TAG%"
echo URANIUM_BRANCH_OR_TAG        = "%URANIUM_BRANCH_OR_TAG%"
echo CURAENGINE_BRANCH_OR_TAG     = "%CURAENGINE_BRANCH_OR_TAG%"
echo CURABINARYDATA_BRANCH_OR_TAG = "%CURABINARYDATA_BRANCH_OR_TAG%"
echo FDMMATERIALS_BRANCH_OR_TAG   = "%FDMMATERIALS_BRANCH_OR_TAG%"
echo
echo CURA_VERSION_MAJOR = "%CURA_VERSION_MAJOR%"
echo CURA_VERSION_MINOR = "%CURA_VERSION_MINOR%"
echo CURA_VERSION_PATCH = "%CURA_VERSION_PATCH%"
echo CURA_VERSION_EXTRA = "%CURA_VERSION_EXTRA%"
echo
echo CURA_BUILD_NAME             = "%CURA_BUILD_NAME%"
echo CURA_CLOUD_API_ROOT         = "%CURA_CLOUD_API_ROOT%"
echo CURA_CLOUD_API_VERSION      = "%CURA_CLOUD_API_VERSION%"
echo CURA_CLOUD_ACCOUNT_API_ROOT = "%CURA_CLOUD_ACCOUNT_API_ROOT%"
echo
echo CPACK_GENERATOR = "%CPACK_GENERATOR%"
echo ========== Build Variables END ==========

echo Prepare environment variables ...
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
set PATH=C:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\bin;%PATH%
set PATH=%CURA_BUILD_ENV_PATH%\bin;%PATH%

set cura_build_work_dir=C:\temp\cura-build
echo Prepare work directory "%cura_build_work_dir%" ...
mkdir %cura_build_work_dir%
echo "Copying %CURA_BUILD_SRC_PATH% to %cura_build_work_dir%"
robocopy /e "%CURA_BUILD_SRC_PATH%" "%cura_build_work_dir%\src"
cd /d %cura_build_work_dir%\src

cmake -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%CURA_BUILD_ENV_PATH%" ^
      -DBUILD_OS_WIN64=ON ^
      -DSIGN_PACKAGE=OFF ^
      -DCURA_BRANCH_OR_TAG="%CURA_BRANCH_OR_TAG%" ^
      -DURANIUM_BRANCH_OR_TAG="%URANIUM_BRANCH_OR_TAG%" ^
      -DCURAENGINE_BRANCH_OR_TAG="%CURAENGINE_BRANCH_OR_TAG%" ^
      -DCURABINARYDATA_BRANCH_OR_TAG="%CURABINARYDATA_BRANCH_OR_TAG%" ^
      -DFDMMATERIALS_BRANCH_OR_TAG="%FDMMATERIALS_BRANCH_OR_TAG%" ^
      -DCURA_VERSION_MAJOR="%CURA_VERSION_MAJOR%" ^
      -DCURA_VERSION_MINOR="%CURA_VERSION_MINOR%" ^
      -DCURA_VERSION_PATCH="%CURA_VERSION_PATCH%" ^
      -DCURA_VERSION_EXTRA="%CURA_VERSION_EXTRA%" ^
      -DCURA_BUILD_NAME="%CURA_BUILD_NAME%" ^
      -DCURA_CLOUD_API_ROOT="%CURA_CLOUD_API_ROOT%" ^
      -DCURA_CLOUD_API_VERSION="%CURA_CLOUD_API_VERSION%" ^
      -DCURA_CLOUD_ACCOUNT_API_ROOT="%CURA_CLOUD_ACCOUNT_API_ROOT%" %CMAKE_EXTRA_ARGS% ^
      -DCPACK_GENERATOR="%CPACK_GENERATOR%" ^
      -G "NMake Makefiles" ^
      .
nmake
nmake package

rem Copy all build data
robocopy /e %cura_build_work_dir%\src %CURA_BUILD_OUTPUT_PATH%\build

echo Copying the installer to the mounted volume ...
copy /y "Ultimaker Cura*.exe" %CURA_BUILD_OUTPUT_PATH%\
