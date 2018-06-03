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
