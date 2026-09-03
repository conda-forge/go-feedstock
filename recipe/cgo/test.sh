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
# scripts expand `-fdebug-prefix-map=$SRC_DIR=...` into `-fdebug-prefix-map==...`,
# i.e. with an empty old-path.
# See https://github.com/prefix-dev/rattler-build/issues/2793
#
# Go's cgo flag allow-list requires a non-empty old-path
# (`-fdebug-prefix-map=([^@]+)=([^@]+)` in cmd/go/internal/work/security.go), so
# the flag is rejected and the whole flag set is treated as "suspicious". Go then
# emits a `preferlinkext` token that forces *external* linking for every cgo
# build, which breaks the many cmd/link, cmd/nm, cmd/objdump and
# cmd/internal/archive tests that assume internal linking.
#
# Note this has to scrub CFLAGS/CXXFLAGS/FFLAGS, not just the CGO_* variants:
# patch 0003 makes Go fall back to CFLAGS when CGO_CFLAGS is empty, so clearing
# only CGO_CFLAGS would just reintroduce the same flag from CFLAGS.
strip_empty_prefix_map() {
  printf '%s' "$1" | sed -E 's/-f(debug|file)-prefix-map==[^[:space:]]*//g'
}
for _var in CFLAGS CXXFLAGS FFLAGS CPPFLAGS \
            CGO_CFLAGS CGO_CXXFLAGS CGO_FFLAGS CGO_CPPFLAGS; do
  eval "_val=\${$_var:-}"
  if [ -n "$_val" ]; then
    eval "export $_var=\"\$(strip_empty_prefix_map \"\$_val\")\""
  fi
done
unset _var _val

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
    case $(go env GOARCH) in
      ppc64le | riscv64)
        # These are cross-compiled, so the test suite runs under qemu, where
        # `go tool dist test` is not viable: ptrace and waitid are unimplemented,
        # getcwd truncates long paths, QEMU_LD_PREFIX redirects / into the sysroot,
        # and the emulator faults in time's tests. Smoke test that the target
        # binaries run and that cgo links instead.
        go version
        mkdir -p smoke && pushd smoke
        go mod init smoke
        cat >main.go <<'EOF'
package main

/*
#include <stdio.h>

void hello(void) { printf("ok\n"); }
*/
import "C"

func main() { C.hello() }
EOF
        go build -o hello .
        ./hello
        popd
        ;;
      *)
        # Expect PASS
        go tool dist test -v -no-rebuild -run='!testsanitizers|runtime'
        # Occasionally FAILS
        go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
        # Expect FAIL
        ;;
    esac
    ;;
esac
