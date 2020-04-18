#!/usr/bin/env bash
set -euf

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"


# Ensure CGO_ENABLED=1
test "$(go env CGO_ENABLED)" == 1


# Print diagnostics
go env


# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS when run independently
    go tool dist test -v -no-rebuild -run='!^go_test:runtime$'
    go tool dist test -v -no-rebuild -run='^go_test:runtime$'
    # Expect FAIL
    ;;
  Linux)
    # Expect PASS
    go tool dist test -v -no-rebuild
    ;;
esac
