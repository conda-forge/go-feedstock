#!/usr/bin/env bash
set -euf

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"


# Ensure CGO_ENABLED=1
test "$(go env CGO_ENABLED)" == 1


# Test GOBIN is set to $PREFIX/bin
test "$(go env GOBIN)" == "$PREFIX/bin"


# Print diagnostics
go env


# Run go's built-in test (we have to disable CONDA_BUILD)
export CONDA_BUILD=0
case $(uname -s) in
  Darwin)
    # Expect PASS
    go tool dist test -v -no-rebuild -run='!^runtime|runtime:cpu124|net$'
    go tool dist test -v -no-rebuild -run='^runtime$'
    go tool dist test -v -no-rebuild -run='^runtime:cpu124$'
    go tool dist test -v -no-rebuild -run='^net$'
    # Expect FAIL
    ;;
  Linux)
    # Expect PASS
    go tool dist test -v -no-rebuild
    ;;
esac
export CONDA_BUILD=1
