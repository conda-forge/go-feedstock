if [[ $CONDA_BUILD = 1 ]]; then
  export GOPATH="${CONDA_BACKUP_GOPATH}"
  unset CONDA_BACKUP_GOPATH
  if [ -z "$GOPATH" ]; then
    unset GOPATH
  fi
fi
