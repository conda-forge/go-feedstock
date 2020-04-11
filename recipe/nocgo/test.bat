@echo on

rem Put GOTMPDIR on the same drive as the conda prefix (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
set TMP=%PREFIX%\tmp
set TMPDIR=%PREFIX%\tmp
set GOTMPDIR=%PREFIX%\tmp
mkdir "%TMP%


rem Diagnostics
where go
go env


rem Run the failing tests by themselves, this is mostly to get logs
rem They fail on Azure, but succeed on AppVeyor and on local Windows VM
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$


rem Run go's built-in test, we skip the filepath one, and cmd/go
go tool dist test -k -v -no-rebuild -run=!^^go_test:cmd/go$
if errorlevel 1 exit 1


exit 0
