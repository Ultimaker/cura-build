# Signing the Installer and Cura.exe with "signtool.exe"
# Location on my desktop:
# -> C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool.exe
# * Manual: https://msdn.microsoft.com/de-de/library/8s9b9yaz(v=vs.110).aspx

set(WINDOWS_IDENTITIY_PFX_FILE "THE_PFX_FILE_IS_MISSING_HERE!" CACHE STRING "PFX file, which represents the identity of the developer.")
set(WINDOWS_IDENTITIY_PFX_PASSWORD "" CACHE STRING "Password, which unlocks the PFX file (optional)")

set(signtool_OPTIONS /fd SHA256 /a /f ${WINDOWS_IDENTITIY_PFX_FILE})

if(NOT ${WINDOWS_IDENTITIY_PFX_PASSWORD} EQUAL "")
    set(signtool_OPTIONS ${signtool_OPTIONS} /p ${WINDOWS_IDENTITIY_PFX_PASSWORD})
else()
    message(FATAL_ERROR "You can't sign your executables without passing your password here!") # Sadly...
endif()

include(CPackComponent)

cpack_add_component(cura DISPLAY_NAME "Cura Executable and Data Files" REQUIRED)
cpack_add_component(vcredist DISPLAY_NAME "Install Visual Studio 2010 Redistributable")
cpack_add_component(arduino DISPLAY_NAME "Install Arduino Drivers")

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
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Cura ${CURA_VERSION_MAJOR}.${CURA_VERSION_MINOR}")

set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
set(CPACK_NSIS_MUI_FINISHPAGE_RUN "Cura.exe")
set(CPACK_NSIS_MENU_LINKS
    "https://ultimaker.com/en/support/software" "Cura Online Documentation"
    "https://github.com/ultimaker/cura" "Cura Development Resources"
)
if(BUILD_OS_WIN32)
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "32")
else()
    set(CPACK_NSIS_PACKAGE_ARCHITECTURE "64")
endif()

set(CPACK_NSIS_PACKAGE_NAME ${CPACK_PACKAGE_NAME})

include(CPack)

if(EXISTS ${WINDOWS_IDENTITIY_PFX_FILE})
    message(STATUS "Signing executables with: " ${WINDOWS_IDENTITIY_PFX_FILE})
    if(${WINDOWS_IDENTITIY_PFX_PASSWORD})
        message(WARNING "USE WITH CAUTION: Password for the PFX file has been set!")
    endif()
    
    # Signing Cura.exe
    add_custom_command(
        TARGET signing PRE_BUILD
        COMMAND signtool sign ${signtool_OPTIONS} Cura.exe
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
    )

    # Signing CuraEngine.exe
    add_custom_command(
        TARGET signing PRE_BUILD
        COMMAND signtool sign ${signtool_OPTIONS} CuraEngine.exe
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
    )

    # Signing the installer
    add_custom_target(sign_installer) # Sadly "TARGET package POST_BUILD" can't be used in the following add_custom_command()
    if(${BUILD_OS_WIN32})
        set(CURA_INSTALLER_NAME ${CPACK_NSIS_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-win32.exe)
    else()
        set(CURA_INSTALLER_NAME ${CPACK_NSIS_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-win64.exe)
    endif()
    add_custom_command(
        TARGET sign_installer
        COMMAND signtool sign ${signtool_OPTIONS} ${CURA_INSTALLER_NAME}
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
else()
    message(FATAL_ERROR "Could not find the PFX file. Can not sign the executables!")
endif()