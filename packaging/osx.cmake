find_package(cx_freeze 4.3 REQUIRED)

configure_file(setup_osx.py.in setup_osx.py @ONLY)

add_custom_target(build_app ALL)
add_dependencies(build_app cura-binary-data)

foreach(repo ${EXTRA_REPOSITORIES})
    separate_arguments(items UNIX_COMMAND "${repo}")
    list(GET items 0 name)
    add_dependencies(build_app ${name})
endforeach()

add_custom_command(
    TARGET build_app PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/dist
    COMMENT "Cleaning old dist/ directory"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
add_custom_command(
    TARGET build_app POST_BUILD
    COMMAND ${PYTHON_EXECUTABLE} setup_osx.py py2app
    COMMENT "Running py2app"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

install(DIRECTORY ${CMAKE_BINARY_DIR}/dist/Cura.app DESTINATION "." USE_SOURCE_PERMISSIONS)

set(CPACK_GENERATOR "DragNDrop")
