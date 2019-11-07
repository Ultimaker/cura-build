ExternalProject_Add(fdm_materials
    GIT_REPOSITORY https://github.com/ultimaker/fdm_materials
    GIT_TAG origin/${FDMMATERIALS_BRANCH_OR_TAG}
    STEP_TARGETS update
    GIT_SHALLOW 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNALPROJECT_INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)

SetProjectDependencies(TARGET fdm_materials DEPENDS Cura)

add_dependencies(update fdm_materials-update)
