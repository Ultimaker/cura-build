find_package(cx_freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_osx.py.in setup.py @ONLY)

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    COMMAND ${PYTHON_EXECUTABLE} setup.py build
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

install(DIRECTORY ${CMAKE_BINARY_DIR}/package/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)

set(CPACK_GENERATOR "DragNDrop")

add_dependencies(signing package)
