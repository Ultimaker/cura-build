include(FindPythonPackage)

FindPythonPackage(PACKAGE_NAME "cx_Freeze" VERSION_PROPERTY "version")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(cx_Freeze REQUIRED_VARS cx_Freeze_PATH VERSION_VAR cx_Freeze_VERSION)
