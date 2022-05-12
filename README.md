# HOPE Software Toolchain

The `hope-src` repository is a super-repository for the HOPE software
toolchain.

# Cloning the Source

As `hope-src` relies on git submodules, we recommend the following
`.gitconfig` settings:

~~~
[submodule]
        recurse = true
[push]
        recurseSubmodules = on-demand
[diff]
        submodule = log
[status]
        submoduleSummary = true
~~~

Follow these steps to clone the repo and submodules:

1. Clone hope-src (*DO NOT USE `--recursive`*):

~~~
git clone https://github.com/draperlaboratory/hope-src.git
~~~

2. Run `./init-submodules.sh`. This will clone the submodules, excluding private repos.

OR

If you have access to the private repos, run `./init-submodules.sh -p`.

# Building the HOPE Toolchain

This is a step-by-step guide on how to build the HOPE software toolchain.

## Setting Environment Variables

To set the necessary environment variables, run the following command, setting
`ISP` to the directory where tools should be installed:

```
ISP=/your/isp/build/ source ./tools/isp-support/set-env
```

If no `ISP` variable is specified, the default location is `~/.local/isp/`.

## Software Prerequisites

Currently, HOPE development has been tested on Ubuntu 18.04, 20.04 and on RHEL 7

### Ubuntu 18.04

On Ubuntu 18.04 run the following to install the necessary software.

```
./tools/isp-support/install-dependencies-ubuntu1804
```
### Ubuntu 20.04

On Ubuntu 20.04 run the following to install the necessary software.

```
./tools/isp-support/install-dependencies-ubuntu2004
```

### RHEL 7

To run the hope tools on RHEL 7, please follow the instructions from ./tools/isp-support/README-RHEL7.md


## Building

The software can be built using the Makefile provided in this repository.  It is
recommend you run `make` with the `-j#` flag as this will instruct `make` to
perform a parallel build with a maximum of `#` processes.  A good
choice for `#` is the number of CPUs you have which is returned by `nproc`.
Therefore you can run the following:

```
make -j `nproc`
```

### Building and install as root:

1. make sure $HOME doesn't have a .stack directory; stack may want to use it, and if it has a different owner than
root the instalation will fail

2. Run

```
/bin/sudo -E env PATH=$PATH TMPDIR=$TMPDIR LD_LIBRARY_PATH=$LD_LIBRARY_PATH make -j `nproc`
```

Double check the permissions of the newly-created $ISP_PREFIX to ensure that all users have rx permissions
on the directories and binaries and r on other files

## Running Tests

### Bare Metal Tests

```
make test-bare JOBS=auto
```

Note: JOBS allows for parallel test runs. You may specify the number of parallel jobs with `JOBS=N`

### FreeRTOS Tests

```
make test-frtos JOBS=auto
```

# Continuous Integration

Steps to run your changes through Continuous Integration (CI):

1. After updating all the individual repositories, create a new hope-src branch starting with "pr-".
2. Bump the submodules in hope-src with your new repositories.
3. Jenkins will watch for pr-* branches and set build status on hope-src as well as each individual repository.
