if [[ $CONDA_BUILD = 1 ]]; then
  export GOPATH="${CONDA_BACKUP_GOPATH}"
  unset CONDA_BACKUP_GOPATH
  if [ -z "$GOPATH" ]; then
    unset GOPATH
  fi

  export GOBIN="${CONDA_BACKUP_GOBIN}"
  unset CONDA_BACKUP_GOBIN
  if [ -z "$GOBIN" ]; then
    unset GOBIN
  fi
fi

export GOOS="${CONDA_BACKUP_GOOS}"
unset CONDA_BACKUP_GOOS
if [ -z $GOOS ]; then
	unset GOOS
fi

export GOARCH="${CONDA_BACKUP_GOARCH}"
unset CONDA_BACKUP_GOARCH
if [ -z $GOARCH ]; then
	unset GOARCH
fi
