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

install(DIRECTORY ${EXTERNALPROJECT_INSTALL_PREFIX}/arduino
        DESTINATION "."
        COMPONENT "arduino"
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

cpack_add_component(_cura DISPLAY_NAME "Ultimaker Cura Executable and Data Files" REQUIRED)
cpack_add_component(vcredist DISPLAY_NAME "Install Visual Studio 2015 Redistributable")
cpack_add_component(arduino DISPLAY_NAME "Install Arduino Drivers")

set(CPACK_GENERATOR "NSIS")
set(CPACK_PACKAGE_NAME "Ultimaker Cura")
string(REPLACE " " "" CPACK_PACKAGE_NAME_NO_WHITESPACES ${CPACK_PACKAGE_NAME})
set(CPACK_PACKAGE_VENDOR "Ultimaker")
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION ${CURA_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Ultimaker Cura - 3D Printing Software")
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/packaging/cura_license)
set(CPACK_PACKAGE_CONTACT "Ruben Dulek <r.dulek@ultimaker.com>")

set(CPACK_PACKAGE_EXECUTABLES Cura "Ultimaker Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}.${CURA_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Ultimaker Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}")

# CPackNSIS
set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
set(CPACK_NSIS_INSTALLED_ICON_NAME "Cura.ico")
set(CPACK_NSIS_MUI_ICON ${CMAKE_SOURCE_DIR}\\\\packaging\\\\cura.ico)   # note: fails with forward '/'
set(CPACK_NSIS_MUI_UNIICON ${CMAKE_SOURCE_DIR}\\\\packaging\\\\cura.ico)
set(CPACK_PACKAGE_ICON ${CMAKE_SOURCE_DIR}/packaging\\\\cura.ico)
set(CPACK_NSIS_MENU_LINKS
    "https://ultimaker.com/en/support/software" "Online Documentation"
    "https://github.com/ultimaker/cura" "Development Resources"
)

set(CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP ${CMAKE_SOURCE_DIR}\\\\packaging\\\\cura_banner.bmp)    # note: fails with forward '/'
set(CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP ${CMAKE_SOURCE_DIR}\\\\packaging\\\\cura_banner.bmp)
set(CPACK_NSIS_INSTALLER_MUI_FINISHPAGE_RUN_CODE "!define MUI_FINISHPAGE_RUN \\\"$WINDIR\\\\explorer.exe\\\"\n!define MUI_FINISHPAGE_RUN_PARAMETERS \\\"$INSTDIR\\\\Cura.exe\\\"")	# Hack to ensure Cura is not started with admin rights

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
    COMMENT "copying NSIS scripts"
)
