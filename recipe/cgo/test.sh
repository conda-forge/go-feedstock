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
    # Impersonate a GO BUILDER
    go_builder_name=$(go env GOOS)-$(go env GOARCH)-${MACOSX_DEPLOYMENT_TARGET/./_}

    # Expect PASS when run independently
    go tool dist test -v -no-rebuild -run='!^go_test:net/http|go_test:runtime$'
    go tool dist test -v -no-rebuild -race -run='^go_test:runtime/race$'
    GO_BUILDER_NAME=$go_builder_name go tool dist test -run='^testcshared|testcarchive$'

    # Occasionally FAILS
    go tool dist test -v -no-rebuild -run='^go_test:net/http$' || true
    go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
    # Expect FAIL
    ;;
  Linux)
    # Impersonate a GO BUILDER
    go_builder_name=$(go env GOOS)-$(go env GOARCH)-condaforge

    # Fix issue where go tests find a .git/config file in the
    # feedstock root.
    # c.f.: https://github.com/conda-forge/go-feedstock/pull/75#issuecomment-612568766
    pushd $GOROOT; git init; git add --all .; popd

    case $ARCH in
      ppc64le)
        # Expect PASS
        go tool dist test -v -no-rebuild -run='!^go_test:runtime$'
        go tool dist test -v -no-rebuild -race -run='^go_test:runtime/race$'
        GO_BUILDER_NAME=$go_builder_name go tool dist test -run='^testcshared|testcarchive$'
        # Occasionally FAILS
        go tool dist test -v -no-rebuild -run='^go_test:runtime$' || true
        # Expect FAIL
        ;;
      *)
        # Expect PASS
        go tool dist test -v -no-rebuild
        go tool dist test -v -no-rebuild -race -run='^go_test:runtime/race$'
        GO_BUILDER_NAME=$go_builder_name go tool dist test -run='^testcshared|testcarchive$'
        ;;
    esac
    ;;
esac
