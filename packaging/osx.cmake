add_custom_command(
        TARGET packaging PRE_BUILD
        COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "@executable_path/lib" "${EXTERNALPROJECT_INSTALL_PREFIX}/bin/CuraEngine"
        COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "@executable_path/" "${EXTERNALPROJECT_INSTALL_PREFIX}/bin/CuraEngine"
        COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "${CMAKE_PREFIX_PATH}/" "${EXTERNALPROJECT_INSTALL_PREFIX}/bin/CuraEngine"
        COMMAND /Library/Developer/CommandLineTools/usr/bin/install_name_tool -add_rpath "${CMAKE_PREFIX_PATH}/lib/" "${EXTERNALPROJECT_INSTALL_PREFIX}/bin/CuraEngine"
        COMMENT "Modify RPATH for CuraEngine to libArcus"
)

add_custom_command(
        TARGET packaging POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/build
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=$PYTHONPATH:\"${CMAKE_PREFIX_PATH}/lib/python3.10/site-packages/:${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.10/site-packages/\"" ${CMAKE_PREFIX_PATH}/bin/pyinstaller --add-data "${EXTERNALPROJECT_INSTALL_PREFIX}/lib/cura/plugins:plugins" --add-data "${EXTERNALPROJECT_INSTALL_PREFIX}/lib/uranium/plugins:plugins" ${EXTERNALPROJECT_INSTALL_PREFIX}/bin/cura_app.py --collect-all cura --collect-all UM --add-data "${EXTERNALPROJECT_INSTALL_PREFIX}/share/cura/resources:resources" --add-data "${EXTERNALPROJECT_INSTALL_PREFIX}/share/uranium/resources:resources" --add-data "${EXTERNALPROJECT_INSTALL_PREFIX}/lib/python3.10/site-packages/UM/Qt/qml/UM/:resources/qml/UM/"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
