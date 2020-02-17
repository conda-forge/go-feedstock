rem Install [de]activate scripts.

rem Windows only builds for amd64
if %conda_goarch%==native set conda_goarch=amd64

for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1

  rem First, copy them to the work directory
  copy "%RECIPE_DIR%\%%F-go-platform.bat" .
  if errorlevel 1 exit 1

  rem Second, expand the GOOS and GOARCH variables
  rem This is the CGO build, so we can't depend on conda goos variant
  sed -i.bak ^
    -e "s|@GOOS@|windows|g" ^
    -e "s|@GOARCH@|%conda_goarch%|g" "%%F-go-platform.bat"
  if errorlevel 1 exit 1

  rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
  copy "%%F-go-platform.bat" "%PREFIX%\etc\conda\%%F.d\%%F-z61-%PKG_NAME%.bat"
  if errorlevel 1 exit 1
)
