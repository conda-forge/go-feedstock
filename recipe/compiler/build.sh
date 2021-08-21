#!/bin/bash

set -exuo pipefail

if [[ "${target_platform}" == "osx-64" ]]; then
  export GOOS=darwin
  export GOARCH=amd64
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  export GOOS=darwin
  export GOARCH=arm64
elif [[ "${target_platform}" == "linux-64" ]]; then
  export GOOS=linux
  export GOARCH=amd64
elif [[ "${target_platform}" == "linux-aarch64" ]]; then
  export GOOS=linux
  export GOARCH=arm64
elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export GOOS=linux
  export GOARCH=ppc64le
fi

sed -ie "s/\${GOOS}/${GOOS}/" "${RECIPE_DIR}/compiler/activate.sh"
sed -ie "s/\${GOARCH}/${GOARCH}/" "${RECIPE_DIR}/compiler/activate.sh"

if [[ "${go_variant_str}" == "cgo" ]]; then
  sed -ie "s/\${CGO_ENABLED}/1/" "${RECIPE_DIR}/compiler/activate.sh"
else
  sed -ie "s/\${CGO_ENABLED}/0/" "${RECIPE_DIR}/compiler/activate.sh"
fi

# Install [de]activate scripts.
for F in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${F}.d"

  # Copy the rendered [de]activate scripts to $PREFIX/etc/conda/[de]activate.d
  cp "${RECIPE_DIR}/compiler/${F}.sh" "${PREFIX}/etc/conda/${F}.d/${F}-z61-${PKG_NAME}.sh"
done
