find_package(cx_freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_win32.py.in setup.py @ONLY)
add_custom_target(build_bundle)
add_dependencies(packaging build_bundle)
add_dependencies(build_bundle projects)

add_custom_command(
    TARGET build_bundle PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/package
    COMMENT "cleaning old package/ directory"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_command(
    TARGET build_bundle POST_BUILD
    COMMAND ${Python3_EXECUTABLE} setup.py build_exe
    COMMENT "running cx_Freeze"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_command(
    TARGET build_bundle POST_BUILD
    # NOTE: Needs testing here, whether CPACK_SYSTEM_NAME is working good for 64bit builds, too.
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/packaging/cura.ico ${CMAKE_BINARY_DIR}/package/
    COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/package/cura.ico ${CMAKE_BINARY_DIR}/package/Cura.ico
    COMMENT "copying cura.ico as Cura.ico into package/"
)

#
# CURA-6074
# QTBUG-57832
# Patch Qt dialogplugin.dll to avoid adding all available drives as shortcuts for FileDialog.
#
if(BUILD_OS_WINDOWS)
    add_custom_command(
        TARGET build_bundle POST_BUILD
        # NOTE: Needs testing here, whether CPACK_SYSTEM_NAME is working good for 64bit builds, too.
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/packaging/patch_qt5.10_dialogplugin.py ${CMAKE_BINARY_DIR}/package
        COMMENT "CURA-6074 Patching dialogplugin.dll in ${CMAKE_BINARY_DIR}/package"
    )
endif()

install(DIRECTORY ${CMAKE_BINARY_DIR}/package/
        DESTINATION "."
        USE_SOURCE_PERMISSIONS
        COMPONENT "_cura" # Note: _ prefix is necessary to make sure the Cura component is always listed first
)

if(CPACK_GENERATOR MATCHES "NSIS64" OR CPACK_GENERATOR MATCHES "NSIS")
    # Only NSIS needs to have arduino and vcredist
    install(DIRECTORY ${EXTERNALPROJECT_INSTALL_PREFIX}/arduino
            DESTINATION "."
            COMPONENT "arduino"
    )

    install(FILES ${EXTERNALPROJECT_INSTALL_PREFIX}/vcredist_x64.exe
            DESTINATION "."
            COMPONENT "vcredist"
    )

    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "64")

    include(packaging/cpackconfig_nsis.cmake)
    include(CPack)

    add_custom_command(
        TARGET build_bundle POST_BUILD
        # NOTE: Needs testing here, whether CPACK_SYSTEM_NAME is working good for 64bit builds, too.
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/NSIS "${CMAKE_BINARY_DIR}/_CPack_Packages/${CPACK_SYSTEM_NAME}/NSIS"
        COMMENT "copying NSIS scripts"
    )

elseif(CPACK_GENERATOR MATCHES "WIX")
    include(packaging/cpackconfig_wix.cmake)
    include(CPack)
endif()
