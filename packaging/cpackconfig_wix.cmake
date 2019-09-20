include(CPackComponent)

include(packaging/cpackconfig_common.cmake)

# ========================================
# MSI
# ========================================
set(CPACK_WIX_CULTURES "en-US")
set(CPACK_WIX_PRODUCT_GUID "${CURA_MSI_PRODUCT_GUID}")
set(CPACK_WIX_UPGRADE_GUID "${CURA_MSI_UPGRADE_GUID}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/packaging/cura_license.txt")
set(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/packaging/cura.ico")
set(CPACK_WIX_UI_BANNER "${CMAKE_SOURCE_DIR}/packaging/cura_banner_msi.bmp")
set(CPACK_WIX_UI_DIALOG "${CMAKE_SOURCE_DIR}/packaging/cura_background_msi.bmp")
set(CPACK_WIX_PROGRAM_MENU_FOLDER "Ultimaker Cura")

set(CPACK_WIX_TEMPLATE "${CMAKE_SOURCE_DIR}/packaging/cura.wxs")
