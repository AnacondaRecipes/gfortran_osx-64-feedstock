#!/bin/bash

CBUILD=${HOST}
CHOST=${macos_machine}
# We do not use -fopenmp here even though it *may* be possible to.
FFLAGS="-ftree-vectorize -fPIC -fstack-protector -O2 -pipe"
DEBUG_FFLAGS="-ftree-vectorize -fPIC -fstack-protector -O2 -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments"

if [[ "$cross_target_platform" == "osx-64" ]]; then
  export FFLAGS="-march=core2 -mtune=haswell ${FFLAGS}"
  export DEBUG_FFLAGS="-march=core2 -mtune=haswell ${DEBUG_FFLAGS}"
fi
if [[ "$cross_target_platform" == "osx-arm64" ]]; then
  export FFLAGS="-march=armv8.3-a ${FFLAGS}"
  export DEBUG_FFLAGS="-march=armv8.3-a ${DEBUG_FFLAGS}"
  export FFLAGS=${FFLAGS//"-fstack-protector"/"-fno-stack-protector"}
  export DEBUG_FFLAGS=${DEBUG_FFLAGS//"-fstack-protector"/"-fno-stack-protector"}
fi

# pushd ${PREFIX}/bin
#   # It is expected this will be built on macOS only:
#   ln -s gfortran ${BUILD}-gfortran
# popd

if [[ "$target_platform" == "$cross_target_platform" ]]; then
  export CONDA_BUILD_CROSS_COMPILATION=""
else
  export CONDA_BUILD_CROSS_COMPILATION="1"
fi

find "${RECIPE_DIR}" -name "*activate*.sh" -exec cp {} . \;

find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${CHOST}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CBUILD@|${CBUILD}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@FFLAGS@|${FFLAGS}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_FFLAGS@|${DEBUG_FFLAGS}|g" "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CONDA_BUILD_CROSS_COMPILATION@|${CONDA_BUILD_CROSS_COMPILATION}|g" "{}" \;

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-gfortran.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-gfortran.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
