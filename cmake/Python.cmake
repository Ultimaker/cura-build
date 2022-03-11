# Copyright (c) 2022 Ultimaker B.V.
# cura-build is released under the terms of the AGPLv3 or higher.

if(NOT Python_FOUND)
    GetFromEnvironmentOrCache(
            NAME
                Python_VERSION
            DEFAULT
                3.10
            DESCRIPTION
                "Python Version to use"
            REQUIRED)
    if(APPLE)
        set(Python_FIND_FRAMEWORK NEVER)
    endif()
    find_package(Python ${Python_VERSION} EXACT REQUIRED COMPONENTS Interpreter)
    message(STATUS "Using Python ${Python_VERSION}")
endif()