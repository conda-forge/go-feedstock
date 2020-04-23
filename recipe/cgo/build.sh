set -euf

#
# Use precompiled bootstrap if it exists
if [ -d "${SRC_DIR}"/go-bootstrap ]; then
  export GOROOT_BOOTSTRAP=${SRC_DIR}/go-bootstrap
fi


# Enable CGO, and set compiler flags to match conda-forge settings
export CGO_ENABLED=1
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS=${CPPFLAGS}
export CGO_CXXFLAGS=${CXXFLAGS}
export CGO_LDFLAGS=${LDFLAGS}
case $(uname -s) in
  Darwin)
    # Tell it where to find the MacOS SDK
    export CGO_CPPFLAGS="${CGO_CPPFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    ;;
  Linux)
    # We have to disable garbage collection for sections
    export CGO_LDFLAGS="${CGO_LDFLAGS} -Wl,--no-gc-sections"
    ;;
  *)
    echo "Unknown OS: $(uname -s)"
    exit 1
    ;;
esac


# Hide the full path of the CC and CXX compilers since they get hardcoded here:
#  - ./cmd/go/internal/cfg/zdefaultcc.go
#  - ./cmd/cgo/zdefaultcc.go
# This bug does not show up while running the tests because conda-build does
# not remove the _build_env.
export CC=$(basename ${CC})
export CXX=$(basename ${CXX})


#
# This a fix for https://github.com/golang/go/issues/37485
pushd $SRC_DIR/compiler-rt/lib/tsan/go
goos=$(GOROOT=$GOROOT_BOOTSTRAP $GOROOT_BOOTSTRAP/bin/go env GOOS)
goarch=$(GOROOT=$GOROOT_BOOTSTRAP $GOROOT_BOOTSTRAP/bin/go env GOARCH)
./buildgo.sh
cp race_${goos}_${goarch}.syso $SRC_DIR/go/src/runtime/race
popd $SRC_DIR


#
# continue with the rest of the build
source $RECIPE_DIR/build-base.sh
