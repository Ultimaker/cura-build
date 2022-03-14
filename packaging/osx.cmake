add_custom_command(
        TARGET packaging POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/build
        COMMAND ${CMAKE_COMMAND} -E env "PYTHONPATH=$PYTHONPATH:\"${CMAKE_PREFIX_PATH}/lib/python3.10/site-packages/:${CMAKE_INSTALL_PREFIX}/lib/python3.10/site-packages/\"" ${CMAKE_PREFIX_PATH}/bin/pyinstaller --add-data "${CMAKE_INSTALL_PREFIX}/lib/cura/plugins:plugins" --add-data "${CMAKE_INSTALL_PREFIX}/lib/uranium/plugins:plugins" ${CMAKE_INSTALL_PREFIX}/bin/cura_app.py --collect-all cura --collect-all UM --add-data "${CMAKE_INSTALL_PREFIX}/share/cura/resources:resources" --add-data "${CMAKE_INSTALL_PREFIX}/share/uranium/resources:resources" --add-data "${CMAKE_INSTALL_PREFIX}/lib/python3.10/site-packages/UM/Qt/qml/UM/:resources/qml/UM/"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
