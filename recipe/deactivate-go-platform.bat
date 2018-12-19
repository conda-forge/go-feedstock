@rem restore the old value again
if "%CONDA_BUILD%"==1 (
  @set "GOPATH=%GOPATH_BACKUP%"
  @set "GOPATH_BACKUP="

  @set "PATH=%PATH_BACKUP%"
  @set "PATH_BACKUP="
)

@set "GOOS=%CONDA_GOOS_BACKUP%"
@set "CONDA_GOOS_BACKUP="

@set "GOARCH=%CONDA_GOARCH_BACKUP%"
@set "CONDA_GOARCH_BACKUP="
