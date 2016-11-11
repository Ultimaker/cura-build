set(CPACK_GENERATOR "NSIS")
find_package(cx_freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_win32.py.in setup.py @ONLY)
add_custom_target(build_bundle)
add_dependencies(packaging build_bundle)
add_dependencies(build_bundle projects)

# TODO: Find a variable which holds the needed "win32"/"win64"
#       There is a CPACK* variable which holds this variable, but it doesn't exist at this moment here...
if(${BUILD_OS_WIN32})
    set(NSIS_SCRIPT_COPY_PATH "${CMAKE_BINARY_DIR}/_CPack_Packages/win32/${CPACK_GENERATOR}")
else()
    set(NSIS_SCRIPT_COPY_PATH "${CMAKE_BINARY_DIR}/_CPack_Packages/win64/${CPACK_GENERATOR}")
endif()

add_custom_command(
    TARGET build_bundle POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/${CPACK_GENERATOR} ${NSIS_SCRIPT_COPY_PATH}
    COMMENT "Copying NSIS scripts"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_command(
    TARGET build_bundle PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    COMMENT "Cleaning old build/ directory"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_command(
    TARGET build_bundle POST_BUILD
    COMMAND ${PYTHON_EXECUTABLE} setup.py build_exe
    COMMENT "Running cx_Freeze"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

install(DIRECTORY ${CMAKE_BINARY_DIR}/package/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS
        COMPONENT "cura"
)

if(BUILD_OS_WIN32)
    install(FILES ${EXTERNALPROJECT_INSTALL_PREFIX}/vcredist_x32.exe
            DESTINATION "."
            COMPONENT "vcredist"
            )
else()
    install(FILES ${EXTERNALPROJECT_INSTALL_PREFIX}/vcredist_x64.exe
            DESTINATION "."
            COMPONENT "vcredist"
            )
endif()

install(DIRECTORY ${EXTERNALPROJECT_INSTALL_PREFIX}/arduino DESTINATION "." COMPONENT "arduino")
