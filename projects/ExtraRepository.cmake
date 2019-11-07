foreach(extra_repository ${EXTRA_REPOSITORIES})
    string(REPLACE " " ";" extra_repository ${extra_repository})
    list(LENGTH extra_repository extra_repository_length)
    math(EXPR extra_repository_length "${extra_repository_length}-1")

    if(extra_repository_length LESS 2)
        message(FATAL_ERROR "The entry you have passed is too short: ${extra_repository_length}")
    endif()

    list(GET extra_repository 0 extra_repository_name)
    list(GET extra_repository 1 extra_repository_url)
    list(GET extra_repository 2 extra_repository_cmake_opts)

    if(extra_repository_length GREATER 2)
        foreach(extra_repository_length_current RANGE 3 ${extra_repository_length})
            list(GET extra_repository ${extra_repository_length_current} extra_repository_cmake_opts_next)
            set(extra_repository_cmake_opts "${extra_repository_cmake_opts} ${extra_repository_cmake_opts_next}")
        endforeach()
    endif()

    message(STATUS "Adding extra repository called: ${extra_repository_name}")
    message(STATUS "              ... with GIT-URL: ${extra_repository_url}")
    message(STATUS "         ... and CMake options: ${extra_repository_cmake_opts}")

    ExternalProject_Add(${extra_repository_name}
        GIT_REPOSITORY ${extra_repository_url}
        GIT_TAG origin/master
        STEP_TARGETS update
        GIT_SHALLOW 1
        CMAKE_ARGS ${extra_repository_cmake_opts}
    )

    SetProjectDependencies(TARGET ${extra_repository_name} DEPENDS Cura)

    add_dependencies(update ${extra_repository_name}-update)

endforeach()
