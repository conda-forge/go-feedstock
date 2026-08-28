#!/usr/bin/env bash
set -euf
set -x

echo "Running cgo tests"

# Test we are running GO under $CONDA_PREFIX
test "$(which go)" == "${CONDA_PREFIX}/bin/go"

# Print diagnostics
go env

# Ensure CGO_ENABLED=1
test "$(go env CGO_ENABLED)" == 1

# $SRC_DIR is not set in the test environment, so the compiler activation
# scripts expand `-fdebug-prefix-map=$SRC_DIR=...` to `-fdebug-prefix-map==...`.
# Go's cgo flag allow-list (cmd/go/internal/work/security.go) requires a
# non-empty old-path, so that flag is rejected and the whole CGO_CFLAGS set is
# treated as "suspicious". Go then forces external linking for every cgo build,
# which breaks many cmd/link, cmd/nm and cmd/objdump tests.
strip_empty_prefix_map() {
  printf '%s' "$1" | sed -E 's/-f(debug|file)-prefix-map==[^[:space:]]*//g'
}
export CGO_CFLAGS="$(strip_empty_prefix_map "${CGO_CFLAGS:-}")"
export CGO_CXXFLAGS="$(strip_empty_prefix_map "${CGO_CXXFLAGS:-}")"
export CGO_FFLAGS="$(strip_empty_prefix_map "${CGO_FFLAGS:-}")"

# Ensure runtime/cgo is not stale.
# This will be assumed as stale as we have changed the value of CC since the build.
export CC=$(basename $CC)
go build -x runtime/cgo

if [[ "$(go env GOHOSTOS)" == "darwin" ]]; then
  # Drop this as it is anyways part of the flags and the tests are sensitive to linker warnings
  export LDFLAGS="${LDFLAGS/-Wl,-rpath,$CONDA_PREFIX\/lib/ }"
fi

# Debug output to diagnose failing tests
which gcc || true
go env
export

# Run go's built-in test
case $(uname -s) in
  Darwin)
    # Expect PASS when run independently
    go tool dist test -v -no-rebuild -run='!^net/http|runtime|time|cmd/go/internal/modfetch/codehost'
    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^net/http$' || true
    go tool dist test -v -no-rebuild -run='^runtime$' || true
    go tool dist test -v -no-rebuild -run='^time$' || true
    # Expect FAIL
    ;;
  Linux)
    # Expect PASS
    go tool dist test -v -no-rebuild -run='!testsanitizers|runtime'
    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
    # Expect FAIL
    ;;
esac
