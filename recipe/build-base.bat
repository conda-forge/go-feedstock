rem Do not use GOROOT_FINAL. Otherwise, every conda environment would
rem need its own non-hardlinked copy of go (+100MB per env).
rem It is better to rely on setting GOROOT during environment activation.
rem
rem c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
set "GOROOT=%SRC_DIR%\go"


rem Print diagnostics before starting the build
set

rem Set go bootstrap for windows sources
set "GOROOT_BOOTSTRAP=%SRC_DIR%\go-bootstrap"

pushd "%GOROOT%\src"
call make.bat
if errorlevel 1 exit 1
popd


rem Don't need the cached build objects
rmdir /s /q %GOROOT%\pkg\obj


rem The following should match the build instructions from go-precompiled
mkdir "%PREFIX%\go"
xcopy /s /y /i /q "%GOROOT%\*" "%PREFIX%\go\"
if errorlevel 1 exit 1


rem Remove Invalid UTF-8 Filename and conflict with libarchive
rem c.f. https://github.com/conda-forge/staged-recipes/pull/9535#discussion_r403512142
del "%PREFIX%\go\test\fixedbugs\issue27836.go
if errorlevel 1 exit 1
rmdir /S /Q "%PREFIX%\go\test\fixedbugs\issue27836.dir
if errorlevel 1 exit 1


rem Right now, it's just go and gofmt, but might be more in the future!
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
for %%f in ("%PREFIX%\go\bin\*.exe") do (
  move %%f "%PREFIX%\bin"
  if errorlevel 1 exit 1
)


rem all files in bin are gone
rmdir /q /s "%PREFIX%\go\bin"
if errorlevel 1 exit 1

:: Taken from https://conda-forge.org/docs/maintainer/adding_pkgs/#activate-scripts
setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
