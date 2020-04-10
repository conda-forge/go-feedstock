set -euf

# Disable CGO, and set compilers to /dev/null
export CGO_ENABLED=0
export CC=/dev/null
export CXX=/dev/null
export FC=/dev/null

# Finish the rest of the build
source $RECIPE_DIR/build-dry.sh

