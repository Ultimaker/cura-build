# Copyright 2016 Ultimaker B.V.

find_package(PythonInterp 3.4.0 QUIET)

if(PythonInterp_FOUND)
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE} -c "import scipy; print(scipy.__file__, scipy.__version__)"
        RESULT_VARIABLE _findSciPy_status
        OUTPUT_VARIABLE _findSciPy_output
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

set(SciPy_MODULE "SciPy_MODULE_NOTFOUND")
set(SciPy_VERSION_STR "SciPy_VERSION_STR_NOTFOUND")
if(_findSciPy_status EQUAL 0)
    string(REGEX MATCH "[^ ]+" SciPy_MODULE ${_findSciPy_output})
    string(REGEX MATCH " (.+)" SciPy_VERSION_STR ${_findSciPy_output})
    string(STRIP ${SciPy_VERSION_STR} SciPy_VERSION_STR)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SciPy REQUIRED_VARS SciPy_MODULE VERSION_VAR SciPy_VERSION_STR)
