# hope-src

# Cloning source

~~~
git clone --recursive https://github.com/draperlaboratory/hope-src.git
~~~

# Git configuration

Add to ~/.gitconfig

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

# CI flow

Steps to run your changes through CI:

1. After updating all the individual repositories, create a new hope-src branch starting with "pr-".
2. Bump the submodules in hope-src with your new repositories.
3. Jenkins will watch for pr-* branches and set build status on hope-src as well as each individual repository.
