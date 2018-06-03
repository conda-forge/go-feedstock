setlocal enabledelayedexpansion

rem First, build go1.4 using gcc, then use that go to build go>1.4
set "GOROOT_BOOTSTRAP=%SRC_DIR%\go-bootstrap"
cd "%GOROOT_BOOTSTRAP%\src"
call make.bat
if errorlevel 1 exit 1

rem GOROOT_FINAL has no effect on Windows
set "GOROOT=%SRC_DIR%\go"
set "GOROOT_FINAL=%PREFIX%\go"
set "GOCACHE=off"
cd "%GOROOT%\src"
call all.bat
if errorlevel 1 exit 1

mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%SRC_DIR%\go\*" "%PREFIX%\go\"

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f "%LIBRARY_BIN%"
)

rem all files in bin are gone
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1

rem Copy the rendered [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
rem go finds its *.go files via the GOROOT variable
for %%F in (activate deactivate) do (
  if not exist "%PREFIX%\etc\conda\%%F.d" mkdir "%PREFIX%\etc\conda\%%F.d"
  if errorlevel 1 exit 1
  copy "%RECIPE_DIR%\%%F-go-core.bat" "%PREFIX%\etc\conda\%%F.d\%%F-go-core.bat"
  if errorlevel 1 exit 1
  dir %PREFIX%\etc\conda\%%F.d\
)
