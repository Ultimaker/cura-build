find_package(cx_Freeze 4.3 REQUIRED)
# find_package(AppImageKit REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_linux.py.in setup.py @ONLY)

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    COMMAND ${PYTHON_EXECUTABLE} setup.py build
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    VERBATIM
)
#
#
