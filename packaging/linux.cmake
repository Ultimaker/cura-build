find_package(cx_Freeze 5.0 REQUIRED)
find_package(AppImageKit REQUIRED)

configure_file(${CMAKE_CURRENT_LIST_DIR}/setup_linux.py.in setup.py @ONLY)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/package
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Cleaning old package directory..."
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${Python3_EXECUTABLE} setup.py build
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running cx_Freeze to generate executable..."
)

set(PACKAGE_DIR ${CMAKE_BINARY_DIR}/package)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy cura.desktop ${PACKAGE_DIR}
    COMMENT "Copying icon and desktop file..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy cura-icon.png ${PACKAGE_DIR}
    COMMENT "Copying icon and desktop file..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy cura.sh ${PACKAGE_DIR}/usr/bin/
    COMMENT "Copying shell script..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_CURRENT_LIST_DIR}/linux_mod_rpath.sh ${PACKAGE_DIR}/usr/bin/
    COMMENT "Modify RPATH for ELFs..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND mkdir -p ${PACKAGE_DIR}/usr/share/metainfo/
    COMMAND ${CMAKE_COMMAND} -E copy cura.appdata.xml ${PACKAGE_DIR}/usr/share/metainfo/
    COMMENT "Installing AppStream metadata..."
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

add_custom_command(
    TARGET packaging PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ${APPIMAGEKIT_APPRUN_EXECUTABLE} ${PACKAGE_DIR}
    COMMENT "Copying AppRun executable..."
)

set(APPIMAGE_FILENAME "Cura-${CURA_VERSION}.AppImage")

add_custom_command(
    TARGET packaging POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/${APPIMAGE_FILENAME}
    COMMAND ${APPIMAGEKIT_APPIMAGETOOL_EXECUTABLE} --appimage-extract-and-run ${CMAKE_BINARY_DIR}/package ${APPIMAGE_FILENAME}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
