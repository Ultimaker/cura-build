
include(CMakeParseArguments)

macro(SetProjectDependencies)
    set(_single_value_args TARGET)
    set(_multi_value_args DEPENDS)
    cmake_parse_arguments("" "" "${_single_value_args}" "${_multi_value_args}" ${ARGN})

    list(APPEND ALL_PROJECT_TARGETS ${_TARGET})

    set_property(TARGET ${_TARGET} PROPERTY PROJECT_DEPENDS ${_DEPENDS})
endmacro()

macro(ProcessProjectDependencies)
    set(_single_value_args TARGET)
    cmake_parse_arguments("" "" "${_single_value_args}" "" ${ARGN})

    foreach(_project ${ALL_PROJECT_TARGETS})
        get_property(_depends TARGET ${_project} PROPERTY PROJECT_DEPENDS)
        if(_depends)
            add_dependencies(${_project} ${_depends})
        endif()
        add_dependencies(${_TARGET} ${_project})
    endforeach()
endmacro()
