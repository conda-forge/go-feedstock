@echo on

for /f "delims=" %%G in ('go env GOHOSTOS') do if not "%%G"=="windows" exit /b 1
for /f "delims=" %%G in ('go env GOHOSTARCH') do if not "%%G"=="arm64" exit /b 1
for /f "delims=" %%G in ('go env GOOS') do if not "%%G"=="windows" exit /b 1
for /f "delims=" %%G in ('go env GOARCH') do if not "%%G"=="arm64" exit /b 1
for /f "delims=" %%G in ('go env CGO_ENABLED') do if not "%%G"=="0" exit /b 1

go build -trimpath -o hello_win_arm64.exe "%~dp0hello_win_arm64.go"
if errorlevel 1 exit /b 1

hello_win_arm64.exe
if errorlevel 1 exit /b 1

powershell -NoLogo -NoProfile -NonInteractive -Command ^
  "$bytes = [IO.File]::ReadAllBytes('hello_win_arm64.exe');" ^
  "$peOffset = [BitConverter]::ToInt32($bytes, 0x3c);" ^
  "$machine = [BitConverter]::ToUInt16($bytes, $peOffset + 4);" ^
  "if ($machine -ne 0xaa64) { Write-Error ('expected PE Machine AA64, got 0x{0:X4}' -f $machine); exit 1 }"
if errorlevel 1 exit /b 1

exit /b 0
