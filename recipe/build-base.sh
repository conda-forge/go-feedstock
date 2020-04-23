set -euf

# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"


#
# Use precompiled bootstrap
case $ARCH in
  aarch64|ppc64le)
    export GOROOT_BOOTSTRAP=$SRC_DIR/go-bootstrap
    ;;
  *)
    export GOCACHE=off
    ;;
esac


# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go


#
# Impersonate GO BUILDER
# Run go's built-in test
GO_BUILDER_NAME=${goos}-${goarch}
case $(uname -s) in
  Darwin)
    GO_BUILDER_NAME=${GO_BUILDER_NAME}-${MACOSX_DEPLOYMENT_TARGET/./_}
    ;;
  Linux)
    GO_BUILDER_NAME=${GO_BUILDER_NAME}-condaforge
    ;;
esac
export GO_BUILDER_NAME


# Print diagnostics before building
env | sort


# Build golang
pushd $GOROOT/src
./make.bash -v
popd


# Don't need the cached build objects
rm -fr ${GOROOT}/pkg/obj


# Dropping the verbose option here, +8000 files
cp -a ${GOROOT} ${PREFIX}/go


# Remove Invalid UTF-8 Filename and conflict with libarchive
# c.f. https://github.com/conda-forge/staged-recipes/pull/9535#discussion_r403512142
# c.f. https://github.com/conda-forge/go-feedstock/issues/83
rm -f "${PREFIX}"/go/test/fixedbugs/issue27836.go
rm -rf "${PREFIX}"/go/test/fixedbugs/issue27836.dir

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
