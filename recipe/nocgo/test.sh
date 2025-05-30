#!/usr/bin/env bash

set -euxf

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"


# Ensure CGO_ENABLED=0, and compilers point to /dev/null
test "$(go env CGO_ENABLED)" == 0
test "$(go env CC)" == "/dev/null"
test "$(go env CXX)" == "/dev/null"
export FC=false


# Print diagnostics
which gcc || true
go env


# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS
    go tool dist test -v -no-rebuild -run='!^net/http|runtime|time|crypto/internal/fips140test'
    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^go_test:net/http$' || true
    go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
    go tool dist test -v -no-rebuild -run='^go_test:time$' || true
    # Expect FAIL
    ;;
  Linux)
    # Fix issue where go tests find a .git/config file in the
    # feedstock root.
    # c.f.: https://github.com/conda-forge/go-feedstock/pull/75#issuecomment-612568766
    pushd $GOROOT; git init; git add --all .; popd

    case $ARCH in
      ppc64le)
        # Expect PASS
        go tool dist test -v -no-rebuild -run='!^runtime|crypto/internal/fips140test'
        # Occasionally FAILS
        go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
        # Expect FAIL
        ;;
      *)
        # Expect PASS
        go tool dist test -v -no-rebuild -run='!^archive/tar|crypto/internal/fips140test'
        ;;
    esac
    ;;
esac
