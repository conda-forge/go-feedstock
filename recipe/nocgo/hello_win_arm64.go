package main

import (
	"fmt"
	"runtime"
)

func main() {
	if runtime.GOOS != "windows" || runtime.GOARCH != "arm64" {
		panic(fmt.Sprintf("expected windows/arm64, got %s/%s", runtime.GOOS, runtime.GOARCH))
	}
	fmt.Println("native windows/arm64 nocgo runtime test passed")
}
