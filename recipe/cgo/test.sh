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

# Some Go tests invoke an unprefixed C compiler. The conda-forge toolchain only
# provides a target-prefixed executable in the test environment.
if command -v "$CC" >/dev/null 2>&1; then
  ln -sf "$(command -v "$CC")" "${PREFIX}/bin/gcc"
fi

if [[ "$(go env GOHOSTOS)" == "darwin" ]]; then
  # Drop this as it is anyways part of the flags and the tests are sensitive to linker warnings
  export LDFLAGS="${LDFLAGS/-Wl,-rpath,$CONDA_PREFIX\/lib/ }"
fi

# Run go's built-in test
case $(uname -s) in
  Darwin)
    # `go tool dist test` stopped prefixing run names with `go_test:` in Go 1.21.
    # The stale names below matched nothing, so the negation ran the whole suite
    # in the mandatory invocation and the `|| true` re-runs were no-ops. Use the
    # modern names so the slow/flaky net/http, runtime and time tests are only
    # run (non-fatally) afterwards.
    go tool dist test -v -no-rebuild -run='!^net/http|runtime|time'
    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^net/http$' || true
    go tool dist test -v -no-rebuild -run='^runtime$' || true
    go tool dist test -v -no-rebuild -run='^time$' || true
    # Expect FAIL
    ;;
  Linux)
    # Fix issue where go tests find a .git/config file in the
    # feedstock root.
    # c.f.: https://github.com/conda-forge/go-feedstock/pull/75#issuecomment-612568766
    pushd $GOROOT; git init; git add --all .; popd

    # The cgo net tests use libc's service database. Minimal containers may not
    # provide /etc/services, so keep that environment-specific failure out of
    # the mandatory test run, as the Darwin branch does for flaky tests.
    net_exclude=""
    if [[ ! -e /etc/services ]]; then
      net_exclude="|net$"
    fi

    # Go's plugin test requests the gold linker, which is not shipped by
    # the aarch64 conda-forge binutils package.
    plugin_exclude=""
    if [[ "$CC" == *-* ]] && ! command -v "${CC%-*}-ld.gold" >/dev/null 2>&1; then
      plugin_exclude="|plugin$"
    fi

    # Expect PASS
    go tool dist test -v -no-rebuild -run="!testsanitizers|runtime|cmd/internal/archive${net_exclude}${plugin_exclude}"
    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
    if [[ -n "${net_exclude}" ]]; then
      go tool dist test -v -no-rebuild -run='^net$' || true
    fi
    # Expect FAIL
    ;;
esac
