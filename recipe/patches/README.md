# go-feedstock patches

## <a name="regenerate"></a>Regenerating the patches
The patches in this folder were created as follows:

    hub clone sodre/go
    cd go
    git checkout sodre/feedstock-go<major>.<minor>.<revision>
    git format-patch go<major>.<minor>.<revision> -o ..
    cd ..
    rm -rf go

Then each patch is added to the the patches section in meta.yaml.

## feedstock-go1.14.1
This branch is a rebase of the patches created for [feedstock-go1.12](#feedstock-go1.13.10).
This time we use a different approach that does not require access to sodre/go.
The steps are 1) clone, 2) reapply old patches, 3) rebase, 4) regenerate maibox patch.

  1. Clone golang/go
     ```shell script
     hub clone golang/go
     cd go
     ```
     
  1. Reapply previous patches and delete them
     ```shell script
     git checkout -b feedstock-go1.13.10 go1.13.10
     git am ../*.patch
     cd ..; git rm *.patch; cd go
     ```
     
  1. Rebase the feedstock branch onto 1.14.1
     ```shell script
     git checkout -b feedstock-go1.14.1 feedstock-go1.13.10
     git rebase --onto go1.14.1 go1.13.10 feedstock-go1.14.1 
     # use 🧠 to solve merge conflicts
     ```
     
  1.  (🧠) `i-nocgo-issue10607` had merge conflict.
  
      We kept `cgo` as a +build requirement
      
  1.  (🧠🧠) `f-conda-default-gobin-and-gopath` had a merge conflict
  
      Upstream deleted four tests which caused our patch to not find its starting location.
      Here is the list of deleted tests, they are still deleted.
        - `TestInstallIntoGOBIN`
        - `TestInstallToCurrentDirectoryCreatesExecutable`
        - `TestInstallWithoutDestinationFails`
        - `TestInstallToGOBINCommandLinePackage`
        
      Here are the tests we wrote, and kept in the unit-tests:
    - pytest tests/functional
    g
        - `TestInstallIntoGOBINWithCondaCompiler`
        - `TestInstallIntoGOBINWithCondaBuild`
  
  1. Regenerate the mailbox patches and add them to the feedstock
     ```shell script
     git format-patch go1.14.1 -o ..
     cd ..
     git add *.patch
     ```
  
## <a name="feedstock-go1.13.10"></a>feedstock-go1.13.10
This branch is a rebase of the patches created for [feedstock-go1.12](#feedstock-go1.12).
Here are the steps we took to create it:

### Setup

  1. Clone both golang/go and add the sodre/go fork
        ```shell script
        hub clone golang/go
        cd go
        hub remote add sodre
        git fetch sodre
        ```

### Rebase all the branches onto 1.13.10
The next step is to rebase the 1.12.x patches onto 1.13.x.
The process is the same for each of the branches, the complications are the merge conflicts.
Solving the merge conflicts is a mix of 🎨 and 🔬.
We subjectively rated the rebase process from 🥬(easy) to  🧠🧠🧠(hard).
This scale is only valid within the 1.13.10 rebase process.

If you need push access to sodre/go's repository, please contact him.

  1.  (🥬) `i-nocgo-issue10607` had no conflicts
        ```shell script
        git checkout -b i-nocgo-issue10607.go1.13 sodre/i-nocgo-issue10607
        git rebase \
            --onto go1.13.10 go1.12.17 \
            i-nocgo-issue10607.go1.13   
        git push -u sodre i-nocgo-issue10607.go1.13.10
        ```
        
  1. (🧠) `i-conda-gfortran-tests` had merge conflicts 
      We still kept our version.
  
        ```shell script
        git checkout -b i-conda-gfortran-tests.go1.13 \
            sodre/i-conda-gfortran-tests.go1.12
        git rebase --onto go1.13.10 go1.12.17 \
                i-conda-gfortran-tests.go1.13.10
        # use 🧠 to solve merge conflicts
        git push -u sodre i-conda-gfortran-tests.go1.13.10
        ```
        
  1. (🧠🧠) `f-conda-default-compiler-flags` had merge conflicts.
      Upstream also started preserving additional environment variables when running their tests.
      It might be a good idea to ask upstream to merge the non-conda specific part of the patch as well.
      
        ```shell script
        git checkout -b f-conda-default-compiler-flags.go1.13.10 \
            sodre/f-conda-default-compiler-flags.go1.12    
        git rebase --onto go1.13.10 go1.12.17 \
            f-conda-default-compiler-flags.go1.13.10
        # Use 🧠 to solve merge conflicts
        git push -u sodre f-conda-default-compiler-flags.go1.13.10
        ```
        
  1. (🧠🧠🧠) `f-conda-default-gobin-and-gopath` had merge conflicts.
  
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

Regenerate the patches according to the [instructions](#regenerate)


    
## <a name="feedstock-go1.12"></a>feedstock-go1.12
The sodre/go?ref=feedstock-go1.12 branch was created by merging
the following individual branches:

  - i-nocgo-issue10607
  - f-conda-default-compiler-flags.go1.12
  - f-conda-default-gobin-and-gopath.go1.12
  - i-conda-gfortran-tests.go1.12

