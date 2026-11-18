@echo on

rem Some of the windows build hosts can be a bit slow.  Allow the tests to run longer on windows under cgo.
set "GO_TEST_TIMEOUT_SCALE=4"

rem Put TMP on the same drive as the conda prefix (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
if /I not "%target_platform%"=="win-arm64" (
  set "TMP=%PREFIX%\tmp"
  mkdir "%PREFIX%\tmp"
)


rem Batch equivalent to backticks
rem   https://stackoverflow.com/questions/2768608/batch-equivalent-of-bash-backticks#2768660
rem for /f "usebackq tokens=*" %%a in (`go env GOEXE`) do file hello%%a | grep '{{ conda_gofile }}'


rem Diagnostics
where go
go env


if /I "%target_platform%"=="win-arm64" goto :win_arm64_tests


rem Run go's built-in tests
rem Expect FAIL, we run them to obtain logs
go tool dist test -k -v -no-rebuild -run=^^go_test:os$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$ || cmd /K "exit /b 0"
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/gofmt$  || cmd /K "exit /b 0"


rem Expect PASS
go tool dist test -v -no-rebuild -run=!^^go_test:os^|go_test:cmd/go^|go_test:cmd/gofmt$  || cmd /K "exit /b 0"
if errorlevel 1 exit 1

goto :done

:win_arm64_tests
rem Match the compiler used by the package before applying CGo test guards.
clang.exe -dumpmachine | findstr /R /I "^aarch64.*windows-msvc" >nul || exit /b 1
set "GO_TEST_MSVC_EXTERNAL_ONLY=1"
set "CGO_LDFLAGS="

rem Exercise the installed defaults, explicit external linking, and PIE.
go run "%~dp0hello_win_arm64.go" || exit /b 1
go run -ldflags="-linkmode=external" "%~dp0hello_win_arm64.go" || exit /b 1
go run -buildmode=pie "%~dp0hello_win_arm64.go" || exit /b 1
go test -count=1 runtime/cgo cmd/cgo/internal/test cmd/cgo/internal/testerrors cmd/cgo/internal/testso cmd/go/internal/work cmd/internal/archive || exit /b 1
go test -count=1 -run="^Test(DefaultExternalLinker|WindowsGDBLinkerScript|MSVCDebugFlags|WindowsMSVC)" cmd/link/internal/ld || exit /b 1
go test -count=1 -run="^TestScript$/^(gccgo_link_ldflags|cgo_suspect_flag_force_external)$" cmd/go || exit /b 1

:done
exit /b 0
