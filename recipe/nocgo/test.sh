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
    case $ARCH in
      ppc64le|riscv64)
        # These are cross-compiled, so the test suite runs under qemu, where
        # `go tool dist test` is not viable: ptrace and waitid are
        # unimplemented, getcwd truncates long paths, QEMU_LD_PREFIX redirects
        # / into the sysroot, and the emulator faults in time's tests.
        # Smoke test that the target binaries actually run instead.
        go version
        mkdir -p smoke && pushd smoke
        go mod init smoke
        cat > main.go <<'EOF'
package main

func main() { println("ok") }
EOF
        go build -o hello .
        ./hello
        popd
        ;;
      *)
        # Expect PASS
        go tool dist test -v -no-rebuild -run='!^archive/tar|crypto/internal/fips140test'
        ;;
    esac
    ;;
esac
