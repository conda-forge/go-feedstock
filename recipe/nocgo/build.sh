set -euf

#
# Use precompiled bootstrap if it exists
if [ -d "${SRC_DIR}"/go-bootstrap ]; then
  export GOROOT_BOOTSTRAP=${SRC_DIR}/go-bootstrap
fi


# Set goos and goarch variables
goos=$(GOROOT=$GOROOT_BOOTSTRAP $GOROOT_BOOTSTRAP/bin/go env GOOS)
goarch=$(GOROOT=$GOROOT_BOOTSTRAP $GOROOT_BOOTSTRAP/bin/go env GOARCH)


# Disable CGO, and set compilers to /dev/null
export CGO_ENABLED=0
export CC=/dev/null
export CXX=/dev/null
export FC=/dev/null


#
# Continue with the rest of the build
source $RECIPE_DIR/build-base.sh
