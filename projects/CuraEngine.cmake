# Copyright (c) 2022 Ultimaker B.V.
# cura-build is released under the terms of the AGPLv3 or higher.

GetFromEnvironmentOrCache(
		NAME
			CURAENGINE_BRANCH_OR_TAG
		DEFAULT
			master
		DESCRIPTION
			"The name of the tag or branch to build for CuraEngine")
GetFromEnvironmentOrCache(
		NAME
			CURA_ENGINE_VERSION
		DEFAULT
			${CURA_VERSION}
		DESCRIPTION
			"The version of CuraEngine")
GetFromEnvironmentOrCache(
		NAME
			CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS
		DEFAULT
			ON
		DESCRIPTION
			"Whether to enable extra compiler optimization flags for CuraEngine"
		BOOL)

if(WIN32)
	file(TO_CMAKE_PATH ${CMAKE_PREFIX_PATH} normalized_prefix_path)
endif()

ExternalProject_Add(CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG origin/${CURAENGINE_BRANCH_OR_TAG}
    GIT_SHALLOW 1
    STEP_TARGETS update
    CMAKE_GENERATOR "$<IF:$<PLATFORM_ID:Windows>,MinGW Makefiles,${CMAKE_GENERATOR}>"
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
               -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
               -DCURA_ENGINE_VERSION=${CURA_ENGINE_VERSION}
               -DENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS=${CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS}
               -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
				$<$<PLATFORM_ID:Windows>:-DArcus_DIR=${CMAKE_PREFIX_PATH}/lib-mingw/cmake/Arcus
										 -DCMAKE_LIBRARY_PATH=${CMAKE_PREFIX_PATH}/lib-mingw
										 -DProtobuf_LIBRARY=${normalized_prefix_path}/lib-mingw/libprotobuf.a
										 -DProtobuf_LITE_LIBRARY=${normalized_prefix_path}/lib-mingw/libprotobuf-lite.a
										 -DProtobuf_PROTOC_LIBRARY=${normalized_prefix_path}/lib-mingw/libprotoc.a>)

SetProjectDependencies(TARGET CuraEngine)

add_dependencies(update CuraEngine-update)
