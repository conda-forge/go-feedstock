if [[ $CONDA_BUILD = 1 ]]; then
  export GOPATH="${GOPATH_BACKUP}"
  unset GOPATH_BACKUP
  if [ -z "$GOPATH" ]; then
    unset GOPATH
  fi

  export PATH="${PATH_BACKUP}"
  unset PATH_BACKUP
  if [ -z "$PATH" ]; then
    unset PATH
  fi
fi

export GOOS="${CONDA_GOOS_BACKUP}"
unset CONDA_GOOS_BACKUP
if [ -z $GOOS ]; then
	unset GOOS
fi

export GOARCH="${CONDA_GOARCH_BACKUP}"
unset CONDA_GOARCH_BACKUP
if [ -z $GOARCH ]; then
	unset GOARCH
fi
