set -euf

# Disable CGO, and set compilers to /dev/null
export CGO_ENABLED=0
export CC=/dev/null
export CXX=/dev/null
export FC=/dev/null


#
# Continue with the rest of the build
source $RECIPE_DIR/build-base.sh
