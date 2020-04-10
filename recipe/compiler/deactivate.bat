@echo off
if "%CONDA_BUILD%x"=="1x" (
  set "GOPATH=%CONDA_BACKUP_GOPATH%"
  set "CONDA_BACKUP_GOPATH="
)
