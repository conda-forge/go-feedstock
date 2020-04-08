# go-feedstock instructions

The go-feedstock builds 2 versions of the go compiler, cgo and nocgo.
The end-user is only allowed to install one in any given conda environment.
This constraint is enforced by conda using the `_go_select` **mutex** package.

The cgo version is built with `CGO_ENABLED=1` and it ties to the conda-forge compilers. 
This is the version that most closely matches the upstream release, with the difference that we use our compilers.
In order to get cgo working, we usually have to patch `go` itself.

The nocgo version is built with `CGO_ENABLED=0` and it only requires the go1.4 bootstrap program to build. 
This version should be easier to build in different architectures, but had the disadvantage of not matching the upstream release as closesly.
