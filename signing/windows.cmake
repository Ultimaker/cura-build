# Signing the Installer and Cura.exe with "signtool.exe"
# Location on my desktop:
# -> C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool.exe
# * Manual: https://msdn.microsoft.com/de-de/library/8s9b9yaz(v=vs.110).aspx

find_package(Signtool REQUIRED)

set(WINDOWS_IDENTITIY_PFX_FILE "THE_PFX_FILE_IS_MISSING_HERE!" CACHE STRING "PFX file, which represents the identity of the developer.")
set(WINDOWS_IDENTITIY_PFX_PASSWORD "" CACHE STRING "Password, which unlocks the PFX file (optional)")

set(signtool_OPTIONS /fd SHA256 /a /f ${WINDOWS_IDENTITIY_PFX_FILE})

if(NOT ${WINDOWS_IDENTITIY_PFX_PASSWORD} EQUAL "")
    set(signtool_OPTIONS ${signtool_OPTIONS} /p ${WINDOWS_IDENTITIY_PFX_PASSWORD})
else()
    message(FATAL_ERROR "You can't sign your executables without passing your password here!") # Sadly...
endif()

if(EXISTS ${WINDOWS_IDENTITIY_PFX_FILE})
    message(STATUS "Signing executables with: " ${WINDOWS_IDENTITIY_PFX_FILE})
    if(${WINDOWS_IDENTITIY_PFX_PASSWORD})
        message(WARNING "USE WITH CAUTION: Password for the PFX file has been set!")
    endif()
    
    # Signing Cura.exe
    add_custom_command(
        TARGET signing PRE_BUILD
        COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} Cura.exe
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
    )

    # Signing CuraEngine.exe
    add_custom_command(
        TARGET signing PRE_BUILD
        COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} CuraEngine.exe
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/package
    )

    # Signing the installer
    add_custom_target(signing-installer) # Sadly "TARGET package POST_BUILD" can't be used in the following add_custom_command()
    set(CURA_INSTALLER_NAME ${CPACK_PACKAGE_FILE_NAME}.exe)
    
    add_custom_command(
        TARGET signing-installer
        COMMAND ${SIGNTOOL_EXECUTABLE} sign ${signtool_OPTIONS} ${CURA_INSTALLER_NAME}
        ## Other optional options:
        # /tr timestampServerUrl 
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
else()
    message(WARNING "Could not find the PFX file. Can not sign the executables!")
endif()