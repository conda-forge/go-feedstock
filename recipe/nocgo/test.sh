#!/usr/bin/env bash
set -euf

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"


# Ensure CGO_ENABLED=0, and compilers point to /dev/null
test "$(go env CGO_ENABLED)" == 0
test "$(go env CC)" == "/dev/null"
test "$(go env CXX)" == "/dev/null"
export FC=false


# Print diagnostics
go env


# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS
    go tool dist test -k -v -no-rebuild -run='!^runtime|runtime:cpu124$'
    go tool dist test -k -v -no-rebuild -run='^runtime$'
    go tool dist test -k -v -no-rebuild -run='^runtime:cpu124$'
    # Expect FAIL
    ;;
  Linux)
    # Expect PASS
    go tool dist test -k -v -no-rebuild
    ;;
esac
