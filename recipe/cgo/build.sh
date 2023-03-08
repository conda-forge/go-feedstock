set -euf

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
    export CGO_LDFLAGS="${CGO_LDFLAGS} -lrt -Wl,--no-gc-sections"
    export GO_LDFLAGS="-extld ${LD} -extldflags \"${LDFLAGS}\""
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
# continue with the rest of the build
source $RECIPE_DIR/build-base.sh
