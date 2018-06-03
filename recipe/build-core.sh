# First, build go1.4 using gcc, then use that go to build go>1.4
export GOROOT_BOOTSTRAP=$SRC_DIR/go-bootstrap
pushd $GOROOT_BOOTSTRAP/src
./make.bash
popd

# Exports copied from
#  https://salsa.debian.org/go-team/compiler/golang/blob/golang-1.10/debian/rules#L9
export GOROOT=$SRC_DIR/go
export GOROOT_FINAL=${PREFIX}/go
export GOCACHE=off
pushd $GOROOT/src
if [[ $(uname) == 'Darwin' ]]; then
  # Tests on macOS receive SIGABRT on Travis :-/
  # All tests run fine on Mac OS X:10.9.5:13F1911 locally
  ./make.bash
elif [[ $(uname) == 'Linux' ]]; then
  ./all.bash
fi
popd

# Dropping the verbose option here, because Travis chokes on output >4MB
cp -a $SRC_DIR/go ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
