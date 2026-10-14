rem Enable CGO and set compiler flags
set "CGO_ENABLED=1"
if /I "%target_platform%"=="win-arm64" set "CGO_LDFLAGS=%LDFLAGS% -fuse-ld=lld"

rem Finish the rest of the build
call "%RECIPE_DIR%\build-base.bat"
if errorlevel 1 exit 1
