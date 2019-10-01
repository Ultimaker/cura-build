cpack_add_component(_cura
                    DISPLAY_NAME "Ultimaker Cura"
                    Description "Ultimaker Cura Executable and Data Files"
                    REQUIRED
)

# ========================================
# CPack Common Settings
# ========================================
set(CPACK_PACKAGE_NAME "Ultimaker Cura")
set(CPACK_PACKAGE_VENDOR "Ultimaker B.V.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/Ultimaker/Cura")

# MSI only supports version format like "x.x.x.x" where x is an integer from 0 to 65534
set(CPACK_PACKAGE_VERSION_MAJOR ${CURA_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CURA_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CURA_VERSION_PATCH})

set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}/packaging/cura.ico")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Ultimaker Cura - 3D Printing Software")
set(CPACK_PACKAGE_CONTACT "Ruben Dulek <r.dulek@ultimaker.com>")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/packaging/cura_license.txt")

set(CPACK_CREATE_DESKTOP_LINKS Cura "Ultimaker Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}")
set(CPACK_PACKAGE_EXECUTABLES Cura "Ultimaker Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Ultimaker Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}")
