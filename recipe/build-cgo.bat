rem Install [de]activate scripts.
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1

  rem First, copy them to the work directory
  copy "%RECIPE_DIR%\%%F-go-cgo.bat" .
  if errorlevel 1 exit 1

  rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
  copy "%%F-go-cgo.bat" "%PREFIX%\etc\conda\%%F.d\%%F-z65-%PKG_NAME%.bat"
  if errorlevel 1 exit 1
)

rem Install stdlib with cgo flag
call "%PREFIX%\etc\conda\activate.d\activate-z65-%PKG_NAME%".bat
"%LIBRARY_BIN%\go" install -a -installsuffix cgo std
