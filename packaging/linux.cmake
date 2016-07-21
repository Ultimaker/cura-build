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
# add_custom_command(
#     TARGET packaging POST_BUILD
#     COMMAND ${PYTHON_EXECUTABLE} setup_osx.py py2app
#     COMMENT "Running py2app"
#     WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
# )
#
# install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)
#
# set(CPACK_GENERATOR "DragNDrop")

#
#
