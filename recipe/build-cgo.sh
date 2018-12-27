set -euf

# Install [de]activate scripts.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"

  # First, copy them to the work directory
  cp "${RECIPE_DIR}/${F}-go-cgo.sh" .

  # Copy the rendered [de]activate scripts to $PREFIX/etc/conda/[de]activate.d
  cp -v "${F}-go-cgo.sh" "${PREFIX}/etc/conda/${F}.d/${F}-z65-${PKG_NAME}.sh"
done

# Install stdlib with cgo flag
source "${PREFIX}/etc/conda/activate.d/activate-z65-${PKG_NAME}.sh"
"${PREFIX}/bin/go" install -a -installsuffix cgo std
