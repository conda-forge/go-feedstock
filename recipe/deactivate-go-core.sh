export GOROOT="${CONDA_GOROOT_BACKUP}"
unset CONDA_GOROOT_BACKUP
if [ -z $GOROOT ]; then
    unset GOROOT
fi
