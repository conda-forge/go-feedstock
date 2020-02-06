About go
========

Home: http://golang.org

Package license: BSD-Style

Feedstock license: BSD 3-Clause

Summary: The Go Programming Language

Go is expressive, concise, clean, and efficient. Its concurrency mechanisms
make it easy to write programs that get the most out of multicore and
networked machines, while its novel type system enables flexible and
modular program construction. Go compiles quickly to machine code yet has
the convenience of garbage collection and the power of run-time reflection.
It's a fast, statically typed, compiled language that feels like a
dynamically typed, interpreted language.


Current build status
====================


<table><tr>
    <td>Travis</td>
    <td>
      <a href="https://travis-ci.com/conda-forge/go-feedstock">
        <img alt="macOS" src="https://img.shields.io/travis/com/conda-forge/go-feedstock/master.svg?label=macOS">
      </a>
    </td>
  </tr><tr>
    <td>Drone</td>
    <td>
      <a href="https://cloud.drone.io/conda-forge/go-feedstock">
        <img alt="linux" src="https://img.shields.io/drone/build/conda-forge/master.svg?label=Linux">
      </a>
    </td>
  </tr>
    
  <tr>
    <td>Azure</td>
    <td>
      <details>
        <summary>
          <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
            <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master">
          </a>
        </summary>
        <table>
          <thead><tr><th>Variant</th><th>Status</th></tr></thead>
          <tbody><tr>
              <td>linux_aarch64_cgofalsenocgotruetarget_platformlinux-aarch64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_aarch64_cgofalsenocgotruetarget_platformlinux-aarch64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_aarch64_cgotruenocgofalsetarget_platformlinux-aarch64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_aarch64_cgotruenocgofalsetarget_platformlinux-aarch64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_cgofalsecgo_int0cgo_varnocgotarget_platformlinux-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_cgofalsecgo_int0cgo_varnocgotarget_platformlinux-64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_cgotruecgo_int1cgo_varcgotarget_platformlinux-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_cgotruecgo_int1cgo_varcgotarget_platformlinux-64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_ppc64le_cgofalsenocgotruetarget_platformlinux-ppc64le</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_ppc64le_cgofalsenocgotruetarget_platformlinux-ppc64le" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>linux_ppc64le_cgotruenocgofalsetarget_platformlinux-ppc64le</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=linux&configuration=linux_ppc64le_cgotruenocgofalsetarget_platformlinux-ppc64le" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>osx_cgofalsenocgotruetarget_platformosx-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=osx&configuration=osx_cgofalsenocgotruetarget_platformosx-64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>osx_cgotruenocgofalsetarget_platformosx-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=osx&configuration=osx_cgotruenocgofalsetarget_platformosx-64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_cgofalsenocgotruetarget_platformwin-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=win&configuration=win_cgofalsenocgotruetarget_platformwin-64" alt="variant">
                </a>
              </td>
            </tr><tr>
              <td>win_cgotruenocgofalsetarget_platformwin-64</td>
              <td>
                <a href="https://dev.azure.com/conda-forge/feedstock-builds/_build/latest?definitionId=5217&branchName=master">
                  <img src="https://dev.azure.com/conda-forge/feedstock-builds/_apis/build/status/go-feedstock?branchName=master&jobName=win&configuration=win_cgotruenocgofalsetarget_platformwin-64" alt="variant">
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </details>
    </td>
  </tr>
</table>

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-go-green.svg)](https://anaconda.org/conda-forge/go) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/go.svg)](https://anaconda.org/conda-forge/go) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/go.svg)](https://anaconda.org/conda-forge/go) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/go.svg)](https://anaconda.org/conda-forge/go) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-go--cgo-green.svg)](https://anaconda.org/conda-forge/go-cgo) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/go-cgo.svg)](https://anaconda.org/conda-forge/go-cgo) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/go-cgo.svg)](https://anaconda.org/conda-forge/go-cgo) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/go-cgo.svg)](https://anaconda.org/conda-forge/go-cgo) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-go--cgo_linux--64-green.svg)](https://anaconda.org/conda-forge/go-cgo_linux-64) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/go-cgo_linux-64.svg)](https://anaconda.org/conda-forge/go-cgo_linux-64) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/go-cgo_linux-64.svg)](https://anaconda.org/conda-forge/go-cgo_linux-64) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/go-cgo_linux-64.svg)](https://anaconda.org/conda-forge/go-cgo_linux-64) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-go--nocgo-green.svg)](https://anaconda.org/conda-forge/go-nocgo) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/go-nocgo.svg)](https://anaconda.org/conda-forge/go-nocgo) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/go-nocgo.svg)](https://anaconda.org/conda-forge/go-nocgo) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/go-nocgo.svg)](https://anaconda.org/conda-forge/go-nocgo) |
| [![Conda Recipe](https://img.shields.io/badge/recipe-go--nocgo_linux--64-green.svg)](https://anaconda.org/conda-forge/go-nocgo_linux-64) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/go-nocgo_linux-64.svg)](https://anaconda.org/conda-forge/go-nocgo_linux-64) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/go-nocgo_linux-64.svg)](https://anaconda.org/conda-forge/go-nocgo_linux-64) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/go-nocgo_linux-64.svg)](https://anaconda.org/conda-forge/go-nocgo_linux-64) |

Installing go
=============

Installing `go` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
```

Once the `conda-forge` channel has been enabled, `go, go-cgo, go-cgo_linux-64, go-nocgo, go-nocgo_linux-64` can be installed with:

```
conda install go go-cgo go-cgo_linux-64 go-nocgo go-nocgo_linux-64
```

It is possible to list all of the versions of `go` available on your platform with:

```
conda search go --channel conda-forge
```


About conda-forge
=================

[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)

conda-forge is a community-led conda channel of installable packages.
In order to provide high-quality builds, the process has been automated into the
conda-forge GitHub organization. The conda-forge organization contains one repository
for each of the installable packages. Such a repository is known as a *feedstock*.

A feedstock is made up of a conda recipe (the instructions on what and how to build
the package) and the necessary configurations for automatic building using freely
available continuous integration services. Thanks to the awesome service provided by
[CircleCI](https://circleci.com/), [AppVeyor](https://www.appveyor.com/)
and [TravisCI](https://travis-ci.com/) it is possible to build and upload installable
packages to the [conda-forge](https://anaconda.org/conda-forge)
[Anaconda-Cloud](https://anaconda.org/) channel for Linux, Windows and OSX respectively.

To manage the continuous integration and simplify feedstock maintenance
[conda-smithy](https://github.com/conda-forge/conda-smithy) has been developed.
Using the ``conda-forge.yml`` within this repository, it is possible to re-render all of
this feedstock's supporting files (e.g. the CI configuration files) with ``conda smithy rerender``.

For more information please check the [conda-forge documentation](https://conda-forge.org/docs/).

Terminology
===========

**feedstock** - the conda recipe (raw material), supporting scripts and CI configuration.

**conda-smithy** - the tool which helps orchestrate the feedstock.
                   Its primary use is in the construction of the CI ``.yml`` files
                   and simplify the management of *many* feedstocks.

**conda-forge** - the place where the feedstock and smithy live and work to
                  produce the finished article (built conda distributions)


Updating go-feedstock
=====================

If you would like to improve the go recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`conda-forge` channel, whereupon the built conda packages will be available for
everybody to install and use from the `conda-forge` channel.
Note that all branches in the conda-forge/go-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@nehaljwani](https://github.com/nehaljwani/)
* [@scopatz](https://github.com/scopatz/)
* [@sodre](https://github.com/sodre/)
* [@stuarteberg](https://github.com/stuarteberg/)

