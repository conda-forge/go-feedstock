set -euf

SHORT_OS_STR=$(uname -s)
if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
    conda_goos=linux
fi
if [ "${SHORT_OS_STR}" == "Darwin" ]; then
    conda_goos=darwin
fi

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
  cp -v "${F}-go-platform.sh" "${PREFIX}/etc/conda/${F}.d/${F}-z61-${PKG_NAME}.sh"
done
