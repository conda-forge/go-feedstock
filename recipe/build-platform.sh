set -euf

# Install [de]activate scripts.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"

  # First, copy them to the work directory
  cp "${RECIPE_DIR}/${F}-go-platform.sh" .

  # Second, expand the GOOS and GOARCH variables
  sed -i.bak \
    -e "s|@GOOS@|${conda_goos}|g" \
    -e "s|@GOARCH@|${conda_goarch}|g" "${F}-go-platform.sh"

  # Copy the rendered [de]activate scripts to $PREFIX/etc/conda/[de]activate.d
  cp -v "${F}-go-platform.sh" "${PREFIX}/etc/conda/${F}.d/${F}-${PKG_NAME}.sh"
done

# Install stdlib with cgo flag
export CGO_ENABLED=0
source "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh"
"${PREFIX}/bin/go" install -a -installsuffix cgo std
