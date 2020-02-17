set -euf

# Make the build more verbose so that we can see
set -x

if [[ ${cgo} == "true" ]]; then
    cgo_var=cgo
else
    cgo_var=nocgo
fi

#
# Install and source the [de]activate scripts.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"
  cp -v "${RECIPE_DIR}/${F}-go-${cgo_var}.sh" "${PREFIX}/etc/conda/${F}.d/${F}-z60-go-${cgo_var}.sh"
done

source "${PREFIX}/etc/conda/activate.d/activate-z60-go-${cgo_var}.sh"

# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go
export GOCACHE=off

# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"
# This is a fix for golang/go#23888
if [ -x "${ADDR2LINE:-}" ]; then
  ln $ADDR2LINE $(dirname $ADDR2LINE)/addr2line
fi

pushd $GOROOT/src
if [[ $(uname) == 'Darwin' ]]; then
  # Tests on macOS receive SIGABRT on Travis :-/
  # All tests run fine on Mac OS X:10.9.5:13F1911 locally
  # issue: golang/go#29160
  ./make.bash
elif [[ $(uname) == 'Linux' ]]; then
  # testsanitizers hangs > 10minutes
  if [[ ${cgo_var} == 'cgo' ]]; then
    export GO_LFFLAGS=${LDFLAGS}
    export GO_EXTLINK_ENABLED=1
    # TODO: For future versions of go
    # export GO_LDSO= ld from conda-forge

    # The go bootstrapper seems to need this for whatever reason
    ln -sf ${CC} ${BUILD_PREFIX}/bin/gcc
    ln -sf ${CXX} ${BUILD_PREFIX}/bin/g++
  fi
  echo "Build: PATH=${PATH}"
  ./make.bash -v
fi
popd

# Don't need the cached build objects
rm -fr ${SRC_DIR}/go/pkg/obj

# Dropping the verbose option here, because Travis chokes on output >4MB
cp -a $SRC_DIR/go ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
