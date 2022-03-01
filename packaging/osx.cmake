find_package(cx_Freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_osx.py.in setup.py @ONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/Info.plist.in Info.plist @ONLY)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "${CMAKE_PREFIX_PATH}/lib" "${EXTERNALPROJECT_INSTALL_PREFIX}/bin/CuraEngine"
    COMMENT "Modify RPATH for CuraEngine to libArcus"
)
add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "${CMAKE_PREFIX_PATH}/lib" "${CMAKE_PREFIX_PATH}/lib/python3.10/site-packages/pynest2d.so"
    COMMENT "Modify RPATH for pynest2d to nlopt & polyclipping"
)

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/build
    COMMAND ${Python3_EXECUTABLE} setup.py bdist_mac
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
