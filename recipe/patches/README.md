# The initial patches - which were created as described below - were manually ported to newer version.
The following steps need to be regarded:
 1. : disable backported patches already in new version available
 2. : rebase patches to new source version. On failure evaluate if
      patches need to be reworked for new sources.
 3. : CGO_LDFLAGS does not need to be adjusted for CONDA's gfortran
 4. : CFLAGS, CPPFLAGS, and LDFLAGS need to be passed through from CONDA's
      compiler settings.
 5. : CONDA_BUILD_SYSROOT, and MACOSX_DEPLOYMENT_TARGET need to be passed
      THROUGH in go's context (cgo).
 6. : For Linux architectures the '-gc-sections' features needs to be turned
      off.
 7. : Conda's MacOSX SDK needs to be provided to go's LDFLAGS.
 8. : Make sure GOBIN uses CONDA's bin directory of current environment
 9. : GOPATH needs to point to CONDA's prefix.
 10.: PPC64LE needs some additional adjustments to be correctly supported by
      go.

===== Historical information =====

# The initial go-feedstock patches were created by the following description:

## <a name="regenerate"></a>Regenerating the patches
The patches in this folder were created as follows:

    hub clone sodre/go
    cd go
    git checkout sodre/feedstock-go<major>.<minor>.<revision>
    git format-patch go<major>.<minor>.<revision> -o ..
    cd ..
    rm -rf go

Then each patch is added to the the patches section in meta.yaml.


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

