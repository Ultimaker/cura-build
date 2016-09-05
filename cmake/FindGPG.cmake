
find_program(GPG_EXECUTABLE gpg)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GPG REQUIRED_VARS GPG_EXECUTABLE)

mark_as_advanced(GPG_EXECUTABLE)
