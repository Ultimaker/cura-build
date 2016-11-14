find_package(cx_freeze 5.0 REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_win32.py.in setup.py @ONLY)
add_custom_target(build_bundle)
add_dependencies(packaging build_bundle)
add_dependencies(build_bundle projects)

add_custom_command(
    TARGET build_bundle PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/package
    COMMENT "Cleaning old package/ directory"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_command(
    TARGET build_bundle POST_BUILD
    COMMAND ${PYTHON_EXECUTABLE} setup.py build_exe
    COMMENT "Running cx_Freeze"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_command(
    TARGET build_bundle POST_BUILD
    # NOTE: Needs testing here, whether CPACK_SYSTEM_NAME is working good for 64bit builds, too.
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/packaging/cura.ico ${CMAKE_BINARY_DIR}/package/
    COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/package/cura.ico ${CMAKE_BINARY_DIR}/package/Cura.ico
    COMMENT "Copying cura.ico as Cura.ico into package/"
)

install(DIRECTORY ${EXTERNALPROJECT_INSTALL_PREFIX}/arduino
        DESTINATION "."
        COMPONENT "arduino"
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

include(CPackComponent)

cpack_add_component(cura DISPLAY_NAME "Cura Executable and Data Files" REQUIRED)
cpack_add_component(vcredist DISPLAY_NAME "Install Visual Studio 2010 Redistributable")
cpack_add_component(arduino DISPLAY_NAME "Install Arduino Drivers")

set(CPACK_GENERATOR "NSIS")
set(CPACK_PACKAGE_NAME "Cura")
set(CPACK_PACKAGE_VENDOR "Ultimaker")
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION ${CURA_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Cura 3D Printing Software")
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE)
set(CPACK_PACKAGE_CONTACT "Arjen Hiemstra <a.hiemstra@ultimaker.com>")

set(CPACK_PACKAGE_EXECUTABLES Cura "Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}.${CURA_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Cura")
set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "Cura")

# CPackNSIS
set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
set(CPACK_NSIS_INSTALL_ROOT ${CMAKE_BINARY_DIR}/package_nsis)
set(CPACK_NSIS_INSTALLED_ICON_NAME "Cura.ico")
set(CPACK_NSIS_MUI_FINISHPAGE_RUN "Cura.exe")
set(CPACK_NSIS_MENU_LINKS
    "https://ultimaker.com/en/support/software" "Cura Online Documentation"
    "https://github.com/ultimaker/cura" "Cura Development Resources"
)

# Needed to call the correct vcredist_x["32", "64"] executable
# TODO: Use a variable, which is already known. For example CPACK_SYSTEM_NAME -> "win32"
if(BUILD_OS_WIN32)
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "32")
else()
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "64")
endif()

set(CPACK_NSIS_PACKAGE_NAME ${CPACK_PACKAGE_NAME})

include(CPack)

add_custom_command(
    TARGET build_bundle POST_BUILD
    # NOTE: Needs testing here, whether CPACK_SYSTEM_NAME is working good for 64bit builds, too.
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/NSIS ${CMAKE_BINARY_DIR}/_CPack_Packages/${CPACK_SYSTEM_NAME}/NSIS
    COMMENT "Copying NSIS scripts"
)