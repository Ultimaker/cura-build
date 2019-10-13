ExternalProject_Add(libCharon
    GIT_REPOSITORY https://github.com/Ultimaker/libCharon
    GIT_TAG origin/${LIBCHARON_BRANCH_OR_TAG}
    STEP_TARGETS update
    GIT_SHALLOW 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET libCharon)

add_dependencies(update libCharon-update)
