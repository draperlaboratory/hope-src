#! /bin/bash

submodules=($(git submodule--helper list | awk '{$1=$2=$3=""; print substr($0,4)}'))

private_submodules=(
  pex-bootrom
  pex-kernel
  pex-firmware
)

usage () {
  echo "Usage: ./init-submodules.sh [-h] [-p]"
  echo "    -h: Display this help message"
  echo "    -p: Clone additional private modules, which include"
  echo "    ${private_submodules[@]}"
}

clone_private=false
while getopts ":hp" opt; do
  case "${opt}" in
    p)
      clone_private=true
      ;;
    h)
      usage && exit 0
      ;;
    ?)
      usage && exit 1
      ;;
  esac
done

echo ${submodules[@]}

echo ${private_submodules[@]}

if [ $clone_private = false ]; then
  for module in ${private_submodules[@]}; do
    echo "Disabling access to $module"
    git config --local submodule."$module".update none
  done
else
  for module in ${private_submodules[@]}; do
    echo "Enabling access to $module"
    git config --local --unset submodule."$module".update
  done
fi


# do some extra steps in the riscv-openocd submodule
# to deal with the upstream repo using a submodule we can't access
GIT_SSL_NO_VERIFY=1 git submodule update --init riscv-openocd
cd riscv-openocd 
GIT_SSL_NO_VERIFY=1 git submodule update --init openocd
cd openocd
# modify the .gitmodule of the openocd to be able to download libjaylink
sed -i 's/gitlab.zapb.de\/libjaylink/github.com\/syntacore/' .gitmodules
cd ../..

# now that we've fixed that submodule url, we can clone submodules as normal
GIT_SSL_NO_VERIFY=1 git submodule update --init --recursive
