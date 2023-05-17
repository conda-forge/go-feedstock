This file lists helpful things to debug common issues with the feedstock.

Compiler flag whitelist
=======================

Go has an internal whitelist on compiler and linker flags that allow for internal linking. This is list is restrictive but not exhaustive.
If we set a flag that isn't in this whitelist (but should be), you can use the following diff to get a better error output:<

```
diff --git a/src/cmd/go/internal/work/security.go b/src/cmd/go/internal/work/security.go
index f4f1880..f5211de 100644
--- a/src/cmd/go/internal/work/security.go
+++ b/src/cmd/go/internal/work/security.go
@@ -231,11 +234,17 @@ var validLinkerFlagsWithNextArg = []string{

 func checkCompilerFlags(name, source string, list []string) error {
 	checkOverrides := true
+	if err := checkFlags(name, source, list, validCompilerFlags, validCompilerFlagsWithNextArg, checkOverrides); err != nil {
+		fmt.Printf("checkCompilerFlags: %s", err.Error())
+	}
 	return checkFlags(name, source, list, validCompilerFlags, validCompilerFlagsWithNextArg, checkOverrides)
 }

 func checkLinkerFlags(name, source string, list []string) error {
 	checkOverrides := true
+	if err := checkFlags(name, source, list, validLinkerFlags, validLinkerFlagsWithNextArg, checkOverrides); err != nil {
+		fmt.Printf("checkLinkerFlags: %s\n", err.Error())
+	}
 	return checkFlags(name, source, list, validLinkerFlags, validLinkerFlagsWithNextArg, checkOverrides)
 }
```
