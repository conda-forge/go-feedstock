rem Enable CGO and set compiler flags
set "CGO_ENABLED=0"

rem Finish the rest of the build
call "%RECIPE_DIR%\build-base.bat"
if errorlevel 1 exit 1