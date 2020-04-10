#!/usr/bin/env bash
set -euf

# Ensure CGO_ENABLED=0
test "$(go env CGO_ENABLED)" == 0

#
# Ensure *default* compilers points to /dev/null
test "$(go env CC)" == "/dev/null"
test "$(go env CXX)" == "/dev/null"
export FC=/dev/null


# Continue with the rest of the tests
source $RECIPE_DIR/test-base.sh
