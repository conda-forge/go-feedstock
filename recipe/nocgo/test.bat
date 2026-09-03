@echo on

rem Put TMP on the same drive as the conda prefix (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
set TMP=%PREFIX%\tmp
mkdir "%TMP%"


rem Diagnostics
where go
go env


if /I "%target_platform%"=="win-arm64" goto :win_arm64_tests


rem Run go's built-in tests
rem Expect FAIL, we run them to obtain logs
go tool dist test -k -v -no-rebuild -run=^^go_test:os$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/gofmt$ || cmd /K "exit /b 0"


rem Expect PASS
go tool dist test -v -no-rebuild -run=!^^go_test:os^|go_test:cmd/go^|go_test:cmd/gofmt$ || cmd /K "exit /b 0"
if errorlevel 1 exit 1

goto :done

:win_arm64_tests
rem cmd/dist resolves go and gofmt under GOROOT, while the conda package
rem exposes them from PREFIX\bin. Restore the canonical layout only in this
rem disposable test prefix.
set "GO_ROOT="
for /f "delims=" %%G in ('go env GOROOT') do set "GO_ROOT=%%G"
if not defined GO_ROOT exit /b 1
if not exist "%GO_ROOT%\bin" mkdir "%GO_ROOT%\bin"
if errorlevel 1 exit /b 1
copy /Y "%PREFIX%\bin\go.exe" "%GO_ROOT%\bin\go.exe"
if errorlevel 1 exit /b 1
copy /Y "%PREFIX%\bin\gofmt.exe" "%GO_ROOT%\bin\gofmt.exe"
if errorlevel 1 exit /b 1

rem Retain the historically tolerated Windows diagnostics, but make the
rem complementary expected-pass suite authoritative for win-arm64.
go tool dist test -k -v -no-rebuild -run=^^go_test:os$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/gofmt$ || cmd /K "exit /b 0"
go tool dist test -v -no-rebuild -run=!^^go_test:os^|go_test:cmd/go^|go_test:cmd/gofmt$
if errorlevel 1 exit /b 1

for /f "delims=" %%G in ('go env GOHOSTOS') do if /I not "%%G"=="windows" exit /b 1
for /f "delims=" %%G in ('go env GOHOSTARCH') do if /I not "%%G"=="arm64" exit /b 1
for /f "delims=" %%G in ('go env GOOS') do if /I not "%%G"=="windows" exit /b 1
for /f "delims=" %%G in ('go env GOARCH') do if /I not "%%G"=="arm64" exit /b 1
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

:done
exit /b 0
