#!/usr/bin/env bash
set -euf

# Ensure CGO_ENABLED=1
test "$(go env CGO_ENABLED)" == 1


# Continue with the rest of the tests
source $RECIPE_DIR/test-base.sh
