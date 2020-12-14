@echo on

rem Put TMP on the same drive as the conda prefix (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
set "TMP=%PREFIX%\tmp"
mkdir "%TMP%"
set "TMPDIR=%TMP%"


rem Batch equivalent to backticks
rem   https://stackoverflow.com/questions/2768608/batch-equivalent-of-bash-backticks#2768660
rem for /f "usebackq tokens=*" %%a in (`go env GOEXE`) do file hello%%a | grep '{{ conda_gofile }}'


rem Diagnostics
where go
go env


rem Expect PASS
go tool dist test -v -no-rebuild
if errorlevel 1 exit 1
go tool dist test -v -no-rebuild -race -run='^go_test:runtime/race$'
if errorlevel 1 exit 1

rem Impersonate go builder
set GO_BUILDER_NAME=windows-amd64-condaforge
go tool dist test -run='^testcshared^|testcarchive$'
if errorlevel 1 exit 1
set "GO_BUILDER_NAME="


exit 0