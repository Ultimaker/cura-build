# Copyright 2016 Ultimaker B.V.

find_package(PythonInterp 3.4.0 QUIET)

if(PythonInterp_FOUND)
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE} -c "import PyQt5.QtCore; print(PyQt5.QtCore.__file__, PyQt5.QtCore.PYQT_VERSION_STR)"
        RESULT_VARIABLE _findPyQt_status
        OUTPUT_VARIABLE _findPyQt_output
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

set(PyQt_CORE_MODULE "PyQt_CORE_MODULE_NOTFOUND")
set(PyQt_VERSION_STR "PyQt_VERSION_STR_NOTFOUND")
if(_findPyQt_status EQUAL 0)
    string(REGEX MATCH "[^ ]+" PyQt_CORE_MODULE ${_findPyQt_output})
    string(REGEX MATCH " .+" PyQt_VERSION_STR ${_findPyQt_output})
    string(STRIP ${PyQt_VERSION_STR} PyQt_VERSION_STR)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PyQt REQUIRED_VARS PyQt_CORE_MODULE VERSION_VAR PyQt_VERSION_STR)
