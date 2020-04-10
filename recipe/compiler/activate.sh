if [[ $CONDA_BUILD = 1 ]]; then
  export CONDA_BACKUP_GOPATH="${GOPATH:-}"
  export GOPATH="$SRC_DIR"
fi
