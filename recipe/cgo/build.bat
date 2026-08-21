rem Enable CGO and set compiler flags
set "CGO_ENABLED=1"

rem MSYS2 clangarm64 toolchain is on PATH via conda; set CC/CXX/FC for cgo.
if /I "%TARGET_PLATFORM%"=="win-arm64" (
  set "CC=clang"
  set "CXX=clang++"
  set "FC=flang"
)

rem Finish the rest of the build
call "%RECIPE_DIR%\build-base.bat"
if errorlevel 1 exit 1
