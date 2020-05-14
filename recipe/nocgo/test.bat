@echo on

rem Put TMP on the same drive as the conda prefix (the D drive),
rem to avoid a known issue in the go test suite:
rem https://github.com/golang/go/issues/24846#issuecomment-381380628
set TMP=%PREFIX%\tmp
mkdir "%TMP%"


rem Diagnostics
where go
go env


rem Run go's built-in tests
rem Expect FAIL, we run them to obtain logs
go tool dist test -k -v -no-rebuild -run=^^go_test:os$
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/go$
go tool dist test -k -v -no-rebuild -run=^^go_test:cmd/gofmt$


rem Expect PASS
go tool dist test -v -no-rebuild -run=!^^go_test:os^|go_test:cmd/go^|go_test:cmd/gofmt$
if errorlevel 1 exit 1


exit 0
