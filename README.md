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
