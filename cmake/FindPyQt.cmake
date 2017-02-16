# Copyright 2016 Ultimaker B.V.

include(FindPythonPackage)

FindPythonPackage(PACKAGE_NAME "PyQt" MODULE_NAME "PyQt5.QtCore" VERSION_PROPERTY "PYQT_VERSION_STR")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PyQt REQUIRED_VARS PyQt_PATH VERSION_VAR PyQt_VERSION)
