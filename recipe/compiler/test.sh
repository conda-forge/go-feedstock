#!/usr/bin/env bash
set -euf

# Test variable is set
test "${CONDA_GO_COMPILER}" == 1


# Test GOBIN is set to $PREFIX/bin
test "$(go env GOBIN)" == "$PREFIX/bin"


# Test GOPATH is set to $SRC_DIR
test "$(go env GOPATH)" == "$SRC_DIR/gopath"


# Print diagnostics
go env
