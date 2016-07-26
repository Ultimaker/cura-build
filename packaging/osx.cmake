find_package(cx_freeze 5.0 REQUIRED)

file(WRITE ${CMAKE_BINARY_DIR}/qt.conf "# Required for Qt to work properly")
configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_osx.py.in setup.py @ONLY)

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/build
    COMMAND ${PYTHON_EXECUTABLE} setup.py bdist_dmg
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
