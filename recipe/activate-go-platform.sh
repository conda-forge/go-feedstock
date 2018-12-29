export CONDA_BACKUP_GOOS="${GOOS:-}"
export GOOS=@GOOS@

export CONDA_BACKUP_GOARCH="${GOARCH:-}"
export GOARCH=@GOARCH@

if [[ $CONDA_BUILD = 1 ]]; then
  export CONDA_BACKUP_GOPATH="${GOPATH:-}"
  export GOPATH="$SRC_DIR"

  export CONDA_BACKUP_GO_PATH="$PATH"
  export PATH="$GOPATH/bin:$PATH"
fi
