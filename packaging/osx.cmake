find_package(cx_freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_osx.py.in setup.py @ONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Info.plist.in Info.plist @ONLY)

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/build
    COMMAND ${Python3_EXECUTABLE} setup.py bdist_mac
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
