#!/bin/bash

set -euxo pipefail

# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"

# Use precompiled bootstrap
export GOROOT_BOOTSTRAP=$SRC_DIR/go-bootstrap

# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go

# xref: https://github.com/golang/go/commit/4739c0db47edf99be9ac1f4beab9ea990570dd5f
if [[ ${CGO_ENABLED} == 1 ]]; then
  if [[ ${CONDA_BUILD_CROSS_COMPILATION:-} == 1 ]]; then
    if [[ "${build_platform}" == "linux-64" ]]; then
      export CC_FOR_linux_amd64=$(basename $CC_FOR_BUILD)
      export CXX_FOR_linux_amd64=$(basename $CXX_FOR_BUILD)
    fi
    # There is no easy way to drop CGO_CFLAGS when compiling go
    # for the build platform during the bootstrapping process
    if [[ "${target_platform}" == "linux-ppc64le" ]]; then
      export CGO_CFLAGS="${CGO_CFLAGS/-mtune=power8 /}"
      export CGO_CFLAGS="${CGO_CFLAGS/-mcpu=power8 /}"
    elif [[ "${target_platform}" == "linux-riscv64" ]]; then
      # -march=rv64imafdc / -mabi=lp64d are rejected by the build platform's
      # compiler, which builds runtime/cgo during bootstrapping.
      export CGO_CFLAGS="$(echo "${CGO_CFLAGS}" | sed -E 's/-m(arch|abi)=[^ ]+ ?//g')"
      export CGO_CXXFLAGS="$(echo "${CGO_CXXFLAGS}" | sed -E 's/-m(arch|abi)=[^ ]+ ?//g')"
    fi
  fi
fi

if [[ "${target_platform}" == "osx-64" ]]; then
  export GOOS=darwin
  export GOARCH=amd64
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export GOOS=darwin
  export GOARCH=arm64
elif [[ "${target_platform}" == "linux-aarch64" ]]; then
  export GOOS=linux
  export GOARCH=arm64
elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export GOOS=linux
  export GOARCH=ppc64le
elif [[ "${target_platform}" == "linux-riscv64" ]]; then
  export GOOS=linux
  export GOARCH=riscv64
elif [[ "${target_platform}" == "linux-64" ]]; then
  export GOOS=linux
  export GOARCH=amd64
else
  echo "Unsupported target_platform: ${target_platform}"
  exit 1
fi

# Print diagnostics before building
env | sort


# Build golang
pushd $GOROOT/src
./make.bash -v
popd


# Don't need the cached build objects
rm -fr ${GOROOT}/pkg/obj

# Don't need the test files from the source
find ${GOROOT}/src -type d -name "testdata" -exec rm -rf \;

# Dropping the verbose option here, +8000 files
cp -a ${GOROOT} ${PREFIX}/go

# When cross-compiling, make.bash puts the build platform binaries in go/bin/
# and the target platform ones in go/bin/${GOOS}_${GOARCH}/. Replace the former
# with the latter, so that we neither ship binaries for the wrong platform nor
# confuse tools that look for $GOROOT/bin/go directly (e.g. `go tool dist test`).
# c.f. https://github.com/conda-forge/go-feedstock/issues/266
if [[ "${build_platform}" != "${target_platform}" ]]; then
  rm -f "${PREFIX}"/go/bin/go "${PREFIX}"/go/bin/gofmt
  # Note: globbing is disabled (set -f), hence find instead of a wildcard
  find "${PREFIX}"/go/bin/${GOOS}_${GOARCH} -type f -exec mv {} "${PREFIX}"/go/bin/ \;
  rmdir "${PREFIX}"/go/bin/${GOOS}_${GOARCH}
fi

# Remove Invalid UTF-8 Filename and conflict with libarchive
# c.f. https://github.com/conda-forge/staged-recipes/pull/9535#discussion_r403512142
# c.f. https://github.com/conda-forge/go-feedstock/issues/83
rm -f "${PREFIX}"/go/test/fixedbugs/issue27836.go
rm -rf "${PREFIX}"/go/test/fixedbugs/issue27836.dir

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_

find ../go/bin -type f -exec ln -s {} . \;

# JSON files under '$PREFIX/etc/conda/env_vars.d/' containing environment variables as key-value pairs
# are sourced automatically upon activation.
# Ref.: https://github.com/conda/conda/issues/6820#issuecomment-1269581626
#
# The build prefix is written out literally; conda rewrites it to the
# installation prefix when the package is unpacked (text prefix replacement).
mkdir -p "${PREFIX}/etc/conda/env_vars.d"
cat > "${PREFIX}/etc/conda/env_vars.d/${PKG_NAME}.json" <<EOF
{
  "GOROOT": "${PREFIX}/go",
  "GOTOOLCHAIN": "local"
}
EOF

# These tests fail as we bake in the compiler path
echo skip > "${PREFIX}/go/src/cmd/go/testdata/script/autocgo.txt"
echo skip > "${PREFIX}/go/src/cmd/go/testdata/script/build_darwin_cc_arch.txt"
