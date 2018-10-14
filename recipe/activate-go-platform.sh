export CONDA_GOOS_BACKUP="${GOOS:-}"
export GOOS=@GOOS@

export CONDA_GOARCH_BACKUP="${GOARCH:-}"
export GOARCH=@GOARCH@

if [[ $CONDA_BUILD == 1 ]]; then
  export GOPATH=$SRC_DIR
fi
