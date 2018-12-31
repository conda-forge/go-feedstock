export CONDA_BACKUP_GOROOT="${GOROOT:-}"
export GOROOT="${CONDA_PREFIX}/go"

export CONDA_BACKUP_CGO_ENABLED="${CGO_ENABLED:-}"
export CGO_ENABLED=0

export CONDA_BACKUP_CGO_CC="${CC:-}"
export CC="/use/the/cgo/conda/package/instead"

export CONDA_BACKUP_CGO_CFLAGS="${CGO_CFLAGS:-}"
export CGO_CFLAGS="--use-the-cgo-conda-package-instead"

export CONDA_BACKUP_CGO_CPPFLAGS="${CGO_CPPFLAGS:-}"
export CGO_CPPFLAGS="--use-the-cgo-conda-package-instead"

export CONDA_BACKUP_CGO_CXX="${CXX:-}"
export CXX="/use/the/cgo/conda/package/instead"

export CONDA_BACKUP_CGO_CXXFLAGS="${CGO_CXXFLAGS:-}"
export CGO_CXXFLAGS="--use-the-cgo-conda-package-instead"

export CONDA_BACKUP_CGO_FFLAGS="${CGO_FFLAGS:-}"
export CGO_FFLAGS="--use-the-cgo-conda-package-instead"

export CONDA_BACKUP_CGO_LDFLAGS="${CGO_LDFLAGS:-}"
export CGO_LDFLAGS="--use-the-cgo-conda-package-instead"
