# go-feedstock patches

## Regenerating the patches
The patches in this folder were created as follows:

    hub clone sodre/go
    cd go
    git checkout sodre/feedstock-go<major>.<minor>.<revision>
    git format-patch go<major>.<minor>.<revision> -o ..
    cd ..
    rm -rf go

Then each patch is added to the the patches section in meta.yaml.


## Creating the feedstock-go1.13.10 branch
This branch is a rebase of the patches applied in go1.12, 
Here are the steps we took to create it:

### Setup

  1. Clone both golang/go and sodre/go
        ```shell script
        hub clone golang/go
        cd go
        hub remote add sodre
        git fetch sodre
        ```

### Rebase all the branches onto 1.13.10
The next step is to rebase the 1.12.x patches onto 1.13.x.
The process is the same for each of the branches, the complications come when there is a merge conflict.

If you need push access to sodre/go's repository, please contact him.

  1.  `i-nocgo-issue10607` -> `i-nocgo-issue10607` remained unchanged(🥬)
        ```shell script
        git checkout -b i-nocgo-issue10607.go1.13 sodre/i-nocgo-issue10607
        git rebase \
            --onto go1.13.10 go1.12.17 \
            i-nocgo-issue10607.go1.13   
        git push -u sodre i-nocgo-issue10607.go1.13.10
        ```
        
  1. `i-conda-gfortran-tests` had merge conflicts(🧠) 
      We still kept our version.
  
        ```shell script
        git checkout -b i-conda-gfortran-tests.go1.13 \
            sodre/i-conda-gfortran-tests.go1.12
        git rebase --onto go1.13.10 go1.12.17 \
                i-conda-gfortran-tests.go1.13.10
        # use 🧠 to solve merge conflicts
        git push -u sodre i-conda-gfortran-tests.go1.13.10
        ```
        
  1. `f-conda-default-compiler-flags.go1.12` had merge conflicts(🧠🧠).
      Upstream also started preserving additional environment variables when running its tests.
      
        ```shell script
        git checkout -b f-conda-default-compiler-flags.go1.13.10 \
            sodre/f-conda-default-compiler-flags.go1.12    
        git rebase --onto go1.13.10 go1.12.17 \
            f-conda-default-compiler-flags.go1.13.10
        # Use 🧠 to solve merge conflicts
        git push -u sodre f-conda-default-compiler-flags.go1.13.10
        ```
        
  1. `f-conda-default-gobin-and-gopath.go1.12` had merge conflicts(🧠🧠🧠)
  
       ```shell script
        git checkout -b f-conda-default-gobin-and-gopath.go1.13.10 \
            sodre/f-conda-default-gobin-and-gopath.go1.12
        git rebase --onto go1.13.10 go1.12.17 \
            f-conda-default-gobin-and-gopath.go1.13.10
        # Use 🧠 to solve merge conflicts
        git push -u sodre f-conda-default-gobin-and-gopath.go1.13.10
        ```
     
### Create the feedstock-1.13.10 branch

    ```shell-script
    git checkout -b feedstock-go1.13.10 go1.13.10
    git merge --no-ff sodre/i-nocgo-issue10607.go1.13.10
    git merge --no-ff sodre/i-conda-gfortran-tests.go1.13.10
    git merge --no-ff sodre/f-conda-default-compiler-flags.go1.13.10
    git merge --no-ff sodre/f-conda-default-gobin-and-gopath.go1.13.10
    
    git push -u sodre feedstock-go1.13.10 
    ```

Regenerate the patches according to the instructions in 


    
## Creating the feedstock-go1.12 branch
The sodre/go?ref=feedstock-go1.12 branch was created by merging
the following individual branches:

  - i-nocgo-issue10607
  - f-conda-default-compiler-flags.go1.12
  - f-conda-default-gobin-and-gopath.go1.12
  - i-conda-gfortran-tests.go1.12


