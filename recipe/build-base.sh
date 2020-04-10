# These are the common build steps between cgo and nocgo

#
# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"


#
# This is a fix for golang/go#23888
if [ -x "${ADDR2LINE:-}" ]; then
  ln $ADDR2LINE $(dirname $ADDR2LINE)/addr2line
fi


#
# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go
export GOCACHE=off


#
# Print diagnostics before building
env | sort


#
# Build golang
pushd $GOROOT/src
./make.bash -v
popd


#
# Don't need the cached build objects, this reduces the package size
rm -fr ${GOROOT}/pkg/obj


#
# Dropping the verbose option here, +8000 files
cp -a ${GOROOT} ${PREFIX}/go


#
# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
