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

@echo off
:: JSON files under '%PREFIX%\etc\conda\env_vars.d\' containing environment variables as key-value pairs
:: are sourced automatically upon activation.
:: Ref.: https://github.com/conda/conda/issues/6820#issuecomment-1269581626
if not exist "%PREFIX%\etc\conda\env_vars.d" mkdir "%PREFIX%\etc\conda\env_vars.d"
copy "%RECIPE_DIR%\env.json" "%PREFIX%\etc\conda\env_vars.d\%PKG_NAME%.json"
