@echo off
if "%CONDA_BUILD%x"=="1x" (
  set "CONDA_BACKUP_GOPATH=%GOPATH%"
  set "GOPATH=%SRC_DIR%"

  set "CONDA_BACKUP_GOBIN=%GOBIN%"
  set "GOBIN=%PREFIX%\bin"
)
