if(BUILD_OS_WINDOWS)
    # Helping CMake on Windows to find Protobuf...
    # Otherwise it claims there is no Protobuf, but there is!
    set(Protobuf_LIBRARY_RELEASE ${CMAKE_PREFIX_PATH}/lib/libprotobuf.a )
    set(Protobuf_LITE_LIBRARY_RELEASE ${CMAKE_PREFIX_PATH}/lib/libprotobuf-lite.a )
    set(Protobuf_PROTOC_LIBRARY_RELEASE ${CMAKE_PREFIX_PATH}/lib/libprotoc.a )
endif()

find_package(Arcus 1.1 REQUIRED)

ExternalProject_Add(CuraEngine
    GIT_REPOSITORY https://github.com/ultimaker/CuraEngine
    GIT_TAG origin/${TAG_OR_BRANCH}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCURA_ENGINE_VERSION=${CURA_VERSION} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -G ${CMAKE_GENERATOR}
)

SetProjectDependencies(TARGET CuraEngine)
