@echo off
set "CONDA_BACKUP_GOROOT=%GOROOT%"
set "GOROOT=%CONDA_PREFIX%\go"

set "CONDA_BACKUP_CGO_ENABLED=%CGO_ENABLED%"
set "CGO_ENABLED=0"

set "CONDA_BACKUP_CGO_CC=%CC%"
set "CC=\use\the\cgo\conda\package\instead"

set "CONDA_BACKUP_CGO_CFLAGS=%CGO_CFLAGS%"
set "CGO_CFLAGS=--use-the-cgo-conda-package-instead"

set "CONDA_BACKUP_CGO_CPPFLAGS=%CGO_CPPFLAGS%"
set "CGO_CPPFLAGS=--use-the-cgo-conda-package-instead"

set "CONDA_BACKUP_CGO_CXX=%CXX%"
set "CXX=\use\the\cgo\conda\package\instead"

set "CONDA_BACKUP_CGO_CXXFLAGS=%CGO_CXXFLAGS%"
set "CGO_CXXFLAGS=--use-the-cgo-conda-package-instead"

set "CONDA_BACKUP_CGO_FFLAGS=%CGO_FFLAGS%"
set "CGO_FFLAGS=--use-the-cgo-conda-package-instead"

set "CONDA_BACKUP_CGO_LDFLAGS=%CGO_LDFLAGS%"
set "CGO_LDFLAGS=--use-the-cgo-conda-package-instead"
