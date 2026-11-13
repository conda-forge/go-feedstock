package main

/*
#include <stdint.h>

static int32_t conda_cgo_add(int32_t left, int32_t right) {
    return left + right;
}
*/
import "C"

import "fmt"

func main() {
	const want = 42
	if got := int(C.conda_cgo_add(19, 23)); got != want {
		panic(fmt.Sprintf("CGo returned %d; want %d", got, want))
	}
	fmt.Println("native Windows ARM64 CGo OK")
}
