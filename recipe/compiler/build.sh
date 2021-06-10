set -euf

# Install [de]activate scripts.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"

  # Copy the rendered [de]activate scripts to $PREFIX/etc/conda/[de]activate.d
  cp "${RECIPE_DIR}/compiler/${F}.sh" "${PREFIX}/etc/conda/${F}.d/${F}-z61-${PKG_NAME}.sh"
done
